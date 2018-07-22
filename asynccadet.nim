import
  gnunet_cadet_service, gnunet_types, gnunet_mq_lib, gnunet_crypto_lib, gnunet_protocols
import
  gnunet_application
import
  asyncdispatch, posix

type
  CadetHandle = object
    handle: ptr GNUNET_CADET_Handle

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

proc connectCadet*(app: GnunetApplication): CadetHandle =
  result = CadetHandle(handle: GNUNET_CADET_connect(app.configHandle))

proc openPort*(handle: CadetHandle, port: string): CadetPort =
  result = CadetPort(handle: nil,
                     channels: newFutureStream[CadetChannel]())
  var handlers = messageHandlers()
  var port = hashString(port)
  result.handle = GNUNET_CADET_open_port(handle.handle,
                                         addr port,
                                         channelConnectCb,
                                         addr result,
                                         nil,
                                         channelDisconnectCb,
                                         addr handlers[0])

proc close*(port: CadetPort) =
  GNUNET_CADET_close_port(port.handle)

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
 
