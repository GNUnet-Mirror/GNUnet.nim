import ../src/gnunet_nim, ../src/gnunet_nim/cadet
import ../asyncdispatch, ../asyncfutures, ../asyncfile
import parseopt
import strutils
import posix

proc firstTask(gnunetApp: ref GnunetApplication,
               peer: string,
               port: string,
               inputFilename: string,
               outputFilename: string) {.async.} =
  var cadet = await gnunetApp.initCadet()
  var cadetChannel: ref CadetChannel
  if (peer == "") and not (port == ""):
    let cadetPort = cadet.openPort(port)
    let (hasChannel, channel) = await cadetPort.channels.read()
    if not hasChannel:
      return
    echo "incoming connection!"
    cadetChannel = channel
  elif not (peer == "") and not (port == ""):
    cadetChannel = cadet.createChannel(peer, port)
  if not (inputFilename == ""):
    let inputFile = openAsync(inputFilename, fmRead)
    while true:
      # 64k is close to the limit of GNUNET_CONSTANTS_MAX_CADET_MESSAGE_SIZE
      let content = await inputFile.read(64_000)
      if content.len() == 0:
        break
      cadetChannel.sendMessage(content)
    inputFile.close()
  elif not (outputFilename == ""):
    let outputFile = openAsync(outputFilename, fmWrite)
    while true:
      let (hasData, message) = await cadetChannel.messages.read()
      if not hasData:
        break
      asyncCheck outputFile.write(message)
    outputFile.close()
  else:
    # We're forced to read from stdin like this because it appears
    # as though the async library cannot do this natively...
    let stdinFile = openAsync("/dev/stdin", fmRead)
    var messagesFuture = cadetChannel.messages.read()
    var stdinFuture = stdinFile.readline()
    while true:
      await messagesFuture or stdinFuture
      if messagesFuture.finished():
        let (hasData, message) = messagesFuture.read()
        if not hasData:
          break
        echo message.strip(leading = false)
        messagesFuture = cadetChannel.messages.read()
      if stdinFuture.finished():
        let input = stdinFuture.read() & '\n'
        cadetChannel.sendMessage(input)
        stdinFuture = stdinFile.readline()
    stdinFile.close()

proc main() =
  var peer, port, configfile, inputFilename, outputFilename: string
  var optParser = initOptParser()
  for kind, key, value in optParser.getopt():
    case kind
    of cmdArgument:
      peer = key
    of cmdLongOption, cmdShortOption:
      case key
      of "port", "p": port = value
      of "config", "c": configfile = value
      of "file", "f": inputFilename = value
      of "output", "o": outputFilename = value
    of cmdEnd:
      assert(false)
  var gnunetApp = initGnunetApplication(configfile)
  asyncCheck firstTask(gnunetApp, peer, port, inputFilename, outputFilename)
  try:
    while true:
      #echo "polling, timeout = ", gnunetApp.millisecondsUntilTimeout()
      poll(gnunetApp.millisecondsUntilTimeout())
      gnunetApp.doWork()
  except ValueError:
    echo "quitting"

main()
GC_fullCollect()
