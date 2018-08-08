import
  gnunet_cadet_service, gnunet_types, gnunet_mq_lib, gnunet_crypto_lib, gnunet_protocols, gnunet_scheduler_lib, gnunet_configuration_lib
import
  gnunet_application, gnunet_utils
import
  asyncdispatch, posix, tables, logging

type
  CadetHandle* = object
    handle: ptr GNUNET_CADET_Handle
    shutdownTask: ptr GNUNET_SCHEDULER_Task

  CadetPort* = object
    handle: ptr GNUNET_CADET_Port
    channels*: FutureStream[ref CadetChannel]

  CadetChannel* = object
    handle: ptr GNUNET_CADET_Channel
    peer*: GNUNET_PeerIdentity
    messages*: FutureStream[string]

proc channelDisconnectCb(cls: pointer,
                         gnunetChannel: ptr GNUNET_CADET_Channel) {.cdecl.} =
  let channel = cast[ptr CadetChannel](cls)
  GNUNET_CADET_receive_done(channel.handle)
  channel.handle = nil
  channel.messages.complete()

proc channelConnectCb(cls: pointer,
                      gnunetChannel: ptr GNUNET_CADET_Channel,
                      source: ptr GNUNET_PeerIdentity): pointer {.cdecl.} =
  let port = cast[ptr CadetPort](cls)
  let channel = new(CadetChannel)
  channel.handle = gnunetChannel
  channel.peer = GNUNET_PeerIdentity(public_key: source.public_key)
  channel.messages = newFutureStream[string]("channelConnectCb")
  waitFor port.channels.write(channel)
  return addr channel[]

proc channelMessageCb(cls: pointer,
                      messageHeader: ptr GNUNET_MessageHeader) {.cdecl.} =
  let channel = cast[ptr CadetChannel](cls)
  GNUNET_CADET_receive_done(channel.handle)
  let payloadLen = int(ntohs(messageHeader.size)) - sizeof(GNUNET_MessageHeader)
  let payload = cast[ptr GNUNET_MessageHeader](cast[ByteAddress](messageHeader) + sizeof(GNUNET_MessageHeader))
  var payloadBuf = newString(payloadLen)
  copyMem(addr payloadBuf[0], payload, payloadLen)
  waitFor channel.messages.write(payloadBuf)

proc channelMessageCheckCb(cls: pointer,
                           messageHeader: ptr GNUNET_MessageHeader): cint {.cdecl.} =
  result = GNUNET_OK

proc messageHandlers(): array[2, GNUNET_MQ_MessageHandler] =
  result = [
    GNUNET_MQ_MessageHandler(mv: channelMessageCheckCb,
                             cb: channelMessageCb,
                             cls: nil,
                             type: GNUNET_MESSAGE_TYPE_CADET_CLI,
                             expected_size: uint16(sizeof(GNUNET_MessageHeader))),
    GNUNET_MQ_MessageHandler(mv: nil,
                             cb: nil,
                             cls: nil,
                             type: 0,
                             expected_size: 0)
  ]

proc hashString(port: string): GNUNET_HashCode =
  GNUNET_CRYPTO_hash(cstring(port), csize(port.len()), addr result)

proc sendMessage*(channel: ref CadetChannel, payload: string) =
  if channel.handle.isNil():
    return
  let messageLen = uint16(payload.len() + sizeof(GNUNET_MessageHeader))
  var messageHeader: ptr GNUNET_MessageHeader
  let envelope = GNUNET_MQ_msg(addr messageHeader,
                               messageLen,
                               GNUNET_MESSAGE_TYPE_CADET_CLI)
  messageHeader = cast[ptr GNUNET_MessageHeader](cast[ByteAddress](messageHeader) + sizeof(GNUNET_MessageHeader))
  copyMem(messageHeader, cstring(payload), payload.len())
  GNUNET_MQ_send(GNUNET_CADET_get_mq(channel.handle), envelope)

proc openPort*(handle: ref CadetHandle, port: string): ref CadetPort =
  let handlers = messageHandlers()
  let port = hashString(port)
  let openPort = new(CadetPort)
  openPort.handle = GNUNET_CADET_open_port(handle.handle,
                                           unsafeAddr port,
                                           channelConnectCb,
                                           addr openPort[],
                                           nil,
                                           channelDisconnectCb,
                                           unsafeAddr handlers[0])
  openPort.channels = newFutureStream[ref CadetChannel]("openPort")
  return openPort

proc close*(port: ref CadetPort) =
  if not port.handle.isNil():
    GNUNET_CADET_close_port(port.handle)
    port.handle = nil
    port.channels.complete()

proc createChannel*(handle: ref CadetHandle,
                    peer: string,
                    port: string): ref CadetChannel =
  var peerIdentity: GNUNET_PeerIdentity
  discard GNUNET_CRYPTO_eddsa_public_key_from_string(peer, #FIXME: don't discard
                                                     peer.len(),
                                                     addr peerIdentity.public_key)
  let handlers = messageHandlers()
  let port = hashString(port)
  let channel = new(CadetChannel)
  channel.peer = peerIdentity
  channel.messages = newFutureStream[string]("createChannel")
  channel.handle = GNUNET_CADET_channel_create(handle.handle,
                                               addr channel[],
                                               addr channel.peer,
                                               unsafeAddr port,
                                               GNUNET_CADET_OPTION_DEFAULT,
                                               nil,
                                               channelDisconnectCb,
                                               unsafeAddr handlers[0])
  return channel

proc close*(channel: ref CadetChannel) =
  if not channel.handle.isNil():
    GNUNET_CADET_channel_destroy(channel.handle)
    channel.handle = nil

proc disconnect(cadetHandle: ptr CadetHandle) =
  if not cadetHandle.handle.isNil():
    GNUNET_CADET_disconnect(cadetHandle.handle)
    cadetHandle.handle = nil

proc shutdownCb(cls: pointer) {.cdecl.} =
  disconnect(cast[ptr CadetHandle](cls))

proc cadetConnectCb(cls: pointer) {.cdecl.} =
  let app = cast[ptr GnunetApplication](cls)
  var future: FutureBase
  if app.connectFutures.take("cadet", future):
    var cadetHandle: ref CadetHandle
    new(cadetHandle, proc(handle: ref CadetHandle) = disconnect(addr handle[]))
    cadetHandle.handle = GNUNET_CADET_connect(app.configHandle)
    cadetHandle.shutdownTask = GNUNET_SCHEDULER_add_shutdown(shutdownCb,
                                                             addr cadetHandle[])
    Future[ref CadetHandle](future).complete(cadetHandle)

proc initCadet*(app: ref GnunetApplication): Future[ref CadetHandle] =
  result = newFuture[ref CadetHandle]("connectCadet")
  app.connectFutures.add("cadet", result)
  discard GNUNET_SCHEDULER_add_now(cadetConnectCb, addr app[])
