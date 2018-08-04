import gnunet_application
import asyncdispatch
import asynccadet
import parseopt

proc cadetListen(gnunetApp: ref GnunetApplication, port: string) {.async.} =
  echo "connecting Cadet"
  var cadet = await gnunetApp.connectCadet()
  echo "connected"
  let cadetPort = cadet.openPort(port)
  echo "port opened"
  let (hasChannel, channel) = await cadetPort.channels.read()
  if hasChannel:
    echo "incoming connection!"
    while true:
      let (hasData, message) = await channel.messages.read()
      if not hasData:
        break;
      echo "got message: ", message

proc cadetConnect(gnunetApp: ref GnunetApplication,
                  peer: string,
                  port: string) {.async.} =
  var cadet = await gnunetApp.connectCadet()
  let cadetChannel = cadet.createChannel(peer, port)
  cadetChannel.sendMessage("hello!")
  while true:
    let (hasData, message) = await cadetChannel.messages.read()
    if not hasData:
      break;
    echo "got message: ", message

proc main() =
  var peer, port: string
  var optParser = initOptParser()
  for kind, key, value in optParser.getopt():
    case kind
    of cmdArgument:
      peer = key
    of cmdLongOption, cmdShortOption:
      case key
      of "port", "p": port = value
    of cmdEnd:
      assert(false)
  var gnunetApp = initGnunetApplication("gnunet.conf")
  echo "peer = ", peer, ", port = ", port
  if peer.isNil() and not port.isNil():
    asyncCheck cadetListen(gnunetApp, port)
  elif not peer.isNil() and not port.isNil():
    asyncCheck cadetConnect(gnunetApp, peer, port)
  try:
    while true:
      #echo "polling, timeout = ", gnunetApp.millisecondsUntilTimeout()
      poll(gnunetApp.millisecondsUntilTimeout())
      gnunetApp.doWork()
  except ValueError:
    echo "quitting"

main()
GC_fullCollect()
