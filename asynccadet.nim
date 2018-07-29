import
  gnunet_cadet_service, gnunet_types, gnunet_mq_lib, gnunet_crypto_lib, gnunet_protocols, gnunet_scheduler_lib, gnunet_configuration_lib
import
  gnunet_application
import
  asyncdispatch, posix, tables, logging

type
  CadetHandle = object
    handle: ptr GNUNET_CADET_Handle
    openPorts: seq[ref CadetPort]

  CadetPort = object
    handle: ptr GNUNET_CADET_Port
    channels*: FutureStream[CadetChannel]

  CadetChannel = object
    handle: ptr GNUNET_CADET_Channel
    peer: GNUNET_PeerIdentity
    messages*: FutureStream[seq[byte]]

proc channelDisconnectCb(cls: pointer,
                         gnunetChannel: ptr GNUNET_CADET_Channel) {.cdecl.} =
  var channel = cast[ptr CadetChannel](cls)
  channel.messages.complete()

proc channelConnectCb(cls: pointer,
                      gnunetChannel: ptr GNUNET_CADET_Channel,
                      source: ptr GNUNET_PeerIdentity): pointer {.cdecl.} =
  var port = cast[ptr CadetPort](cls)
  var channel = CadetChannel(handle: gnunetChannel,
                             peer: GNUNET_PeerIdentity(public_key: source.public_key),
                             messages: newFutureStream[seq[byte]]())
  asyncCheck port.channels.write(channel)
  return addr channel

proc channelMessageCb(cls: pointer,
                      messageHeader: ptr GNUNET_MessageHeader) {.cdecl.} =
  var channel = cast[ptr CadetChannel](cls)
  let payloadLen = int(ntohs(messageHeader.size)) - sizeof(GNUNET_MessageHeader)
  let messageHeader = cast[ptr array[2, GNUNET_MessageHeader]](messageHeader)
  var payloadBuf = newSeq[byte](payloadLen)
  copyMem(addr payloadBuf[0], addr messageHeader[1], payloadLen)
  asyncCheck channel.messages.write(payloadBuf)

proc channelMessageCheckCb(cls: pointer,
                           messageHeader: ptr GNUNET_MessageHeader): cint {.cdecl.} =
  result = GNUNET_OK

proc cadetConnectCb(cls: pointer) {.cdecl.} =
  let app = cast[ptr GnunetApplication](cls)
  echo "cadetConnectCb"
  var future: FutureBase
  if app.connectFutures.take("cadet", future):
    let cadetHandle = CadetHandle(handle: GNUNET_CADET_connect(app.configHandle),
                                  openPorts: newSeq[ref CadetPort]())
    Future[CadetHandle](future).complete(cadetHandle)

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
  var port: cstring = port
  GNUNET_CRYPTO_hash(addr port, port.len(), addr result)

proc sendMessage*(channel: CadetChannel, payload: seq[byte]) =
  let messageLen = uint16(payload.len() + sizeof(GNUNET_MessageHeader))
  var messageHeader: ptr GNUNET_MessageHeader
  var envelope = GNUNET_MQ_msg(addr messageHeader,
                               messageLen,
                               GNUNET_MESSAGE_TYPE_CADET_CLI)
  GNUNET_MQ_send(GNUNET_CADET_get_mq(channel.handle), envelope)

proc openPort*(handle: var CadetHandle, port: string): ref CadetPort =
  var handlers = messageHandlers()
  var port = hashString(port)
  var openPort: ref CadetPort
  new(openPort)
  openPort.channels = newFutureStream[CadetChannel]()
  openPort.handle = GNUNET_CADET_open_port(handle.handle,
                                           addr port,
                                           channelConnectCb,
                                           addr openPort,
                                           nil,
                                           channelDisconnectCb,
                                           addr handlers[0])
  handle.openPorts.add(openPort)
  return openPort

proc closePort*(handle: var CadetHandle, port: ref CadetPort) =
  GNUNET_CADET_close_port(port.handle)
  port.channels.complete()
  handle.openPorts.delete(handle.openPorts.find(port))

proc createChannel*(handle: CadetHandle, peer: string, port: string): CadetChannel =
  var peerIdentity: GNUNET_PeerIdentity
  discard GNUNET_CRYPTO_eddsa_public_key_from_string(peer, #FIXME: don't discard
                                                     peer.len(),
                                                     addr peerIdentity.public_key)
  result = CadetChannel(handle: nil,
                        peer: peerIdentity,
                        messages: newFutureStream[seq[byte]]("createChannel"))
  var handlers = messageHandlers()
  var port = hashString(port)
  result.handle = GNUNET_CADET_channel_create(handle.handle,
                                              addr result,
                                              addr result.peer,
                                              addr port,
                                              GNUNET_CADET_OPTION_DEFAULT,
                                              nil,
                                              channelDisconnectCb,
                                              addr handlers[0])
 
proc connectCadet*(app: ref GnunetApplication): Future[CadetHandle] =
  result = newFuture[CadetHandle]("connectCadet")
  app.connectFutures.add("cadet", result)
  discard GNUNET_SCHEDULER_add_now(cadetConnectCb, addr app[])

proc disconnect*(handle: var CadetHandle) =
  for port in handle.openPorts:
    handle.closePort(port)
  GNUNET_CADET_disconnect(handle.handle)


