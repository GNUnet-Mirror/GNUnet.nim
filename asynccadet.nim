import gnunet_cadet_service, gnunet_types, gnunet_mq_lib, gnunet_protocols
import asyncdispatch, posix

type
  CadetHandle = object
    handle: ptr GNUNET_CADET_Handle

  CadetPort = object
    handle: ptr GNUNET_CADET_Port
    channels*: FutureStream[CadetChannel]

  CadetChannel = object
    handle: ptr GNUNET_CADET_Channel
    peer: ptr GNUNET_PeerIdentity
    messages*: FutureStream[seq[byte]]

proc channelDisconnectCb(cls: pointer,
                         gnunetChannel: ptr GNUNET_CADET_Channel) {.cdecl.} =
  var channel = cast[ptr CadetChannel](cls)
  channel.messages.complete()

proc channelConnectCb(cls: pointer,
                      gnunetChannel: ptr GNUNET_CADET_Channel,
                      source: ptr GNUNET_PeerIdentity) {.cdecl.} =
  var port = cast[ptr CadetPort](cls)
  var channel = CadetChannel(handle: gnunetChannel,
                             peer: source,
                             messages: newFutureStream[seq[byte]]())
  asyncCheck port.channels.write(channel)

proc channelMessageCb(cls: pointer,
                      messageHeader: ptr GNUNET_MessageHeader) {.cdecl.} =
  var channel = cast[ptr CadetChannel](cls)
  # FIXME: is there a less ugly way of doing pointer arithmetic?
  let payload = cast[pointer](
      cast[uint](messageHeader) + uint(sizeof(GNUNET_MessageHeader))
  )
  let payloadLen = int(ntohs(messageHeader.size)) - sizeof(GNUNET_MessageHeader)
  var payloadBuf = newSeq[byte](payloadLen)
  copyMem(addr payloadBuf[0], payload, payloadLen)
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

proc portHash(port: string): GNUNET_HashCode =
  GNUNET_CRYPTO_hash(addr port[0], port.len(), addr result) # FIXME

proc sendMessage*(channel: CadetChannel, payload: seq[byte]) =
  let messageLen = uint16(payload.len() + sizeof(GNUNET_MessageHeader))
  var messageHeader: ptr GNUNET_MessageHeader
  var envelope = GNUNET_MQ_msg(addr messageHeader,
                               messageLen,
                               GNUNET_MESSAGE_TYPE_CADET_CLI)
  GNUNET_MQ_send(GNUNET_CADET_get_mq(channel.handle), envelope)

proc connect*(): CadetHandle =
  var configHandle = #FIXME
  result = CadetHandle(handle: GNUNET_CADET_connect(configHandle))

proc openPort*(handle: CadetHandle, port: string): CadetPort =
  result = CadetPort(handle: nil,
                     channels: newFutureStream[CadetChannel]())
  let handlers = messageHandlers()
  result.handle = GNUNET_CADET_open_port(handle.handle,
                                         port: portHash(port),
                                         connects: channelConnectCb,
                                         connects_cls: addr result,
                                         window_changes: nil,
                                         disconnects: channelDisconnectCb,
                                         handlers: handlers)

proc close*(port: CadetPort) =
  GNUNET_CADET_close_port(port.handle)

proc createChannel*(handle: CadetHandle, peer: GnunetPeer, port: string): CadetChannel =
  result = CadetChannel(handle: nil,
                        peer: peer,
                        messages: newFutureStream[seq[byte]]("createChannel"))
  let handlers = messageHandlers()
  result.handle = GNUNET_CADET_channel_create(h: handle.handle,
                                              channel_cls: addr result,
                                              destination: peer.peerId,
                                              port: portHash(port),
                                              options: GNUNET_CADET_OPTION_DEFAULT,
                                              window_changes: nil,
                                              disconnects: channelDisconnectCb,
                                              handlers: handlers)
 
