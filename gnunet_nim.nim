import gnunet_application
import asyncdispatch, asyncfutures, asyncfile
import asynccadet
import parseopt
import strutils

proc firstTask(gnunetApp: ref GnunetApplication,
               peer: string,
               port: string) {.async.} =
  var cadet = await gnunetApp.connectCadet()
  var cadetChannel: ref CadetChannel
  if peer.isNil() and not port.isNil():
    let cadetPort = cadet.openPort(port)
    let (hasChannel, channel) = await cadetPort.channels.read()
    if (hasChannel):
      echo "incoming connection!"
      cadetChannel = channel
  elif not peer.isNil() and not port.isNil():
    cadetChannel = cadet.createChannel(peer, port)
  let stdinFile = openAsync("/dev/stdin", fmRead)
  while true:
    let messagesFuture = cadetChannel.messages.read()
    let stdinFuture = stdinFile.readLine()
    await messagesFuture or stdinFuture
    if messagesFuture.finished():
      let (hasData, message) = messagesFuture.read()
      if not hasData:
        break;
      echo message.strip(leading = false)
    if stdinFuture.finished():
      let input = stdinFuture.read() & '\n'
      cadetChannel.sendMessage(input)
  stdinFile.close()

proc main() =
  var peer, port, configfile: string
  var optParser = initOptParser()
  for kind, key, value in optParser.getopt():
    case kind
    of cmdArgument:
      peer = key
    of cmdLongOption, cmdShortOption:
      case key
      of "port", "p": port = value
      of "config", "c": configfile = value
    of cmdEnd:
      assert(false)
  var gnunetApp = initGnunetApplication(configfile)
  asyncCheck firstTask(gnunetApp, peer, port)
  try:
    while true:
      #echo "polling, timeout = ", gnunetApp.millisecondsUntilTimeout()
      poll(gnunetApp.millisecondsUntilTimeout())
      gnunetApp.doWork()
  except ValueError:
    echo "quitting"

main()
GC_fullCollect()
