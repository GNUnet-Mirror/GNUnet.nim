import ../gnunet_application, ../asynccadet
import asyncdispatch, asyncfile, parseopt, strutils

type Chat = object
  channels: seq[ref CadetChannel]

proc publish(chat: ref Chat, message: string, sender: ref CadetChannel = nil) =
  let message =
    if sender.isNil(): message.strip(leading = false)
    else: "[Alice] " & message.strip(leading = false)
  echo message
  for c in chat.channels:
    c.sendMessage(message)

proc processClientMessages(channel: ref CadetChannel,
                           chat: ref Chat) {.async.} =
  while true:
    let (hasData, message) = await channel.messages.read()
    if not hasData:
      break
    chat.publish(message = message, sender = channel)

proc processServerMessages(channel: ref CadetChannel) {.async.} =
  let inputFile = openAsync("/dev/stdin", fmRead)
  var inputFuture = inputFile.readline()
  var messageFuture = channel.messages.read()
  while true:
    await inputFuture or messageFuture
    if inputFuture.finished():
      let input = inputFuture.read()
      channel.sendMessage(input)
      inputFuture = inputFile.readline()
    else:
      let (hasData, message) = messageFuture.read()
      if not hasData:
        break
      echo message
      messageFuture = channel.messages.read()

proc firstTask(gnunetApp: ref GnunetApplication,
               server: string,
               port: string) {.async.} =
  let cadet = await gnunetApp.initCadet()
  var chat = new(Chat)
  chat.channels = newSeq[ref CadetChannel]()
  if not server.isNil():
    let channel = cadet.createChannel(server, port)
    processServerMessages(channel).addCallback(shutdownGnunetApplication)
  else:
    let cadetPort = cadet.openPort(port)
    while true:
      let (hasChannel, channel) = await cadetPort.channels.read()
      if not hasChannel:
        break
      chat.publish(message = "X joined\n")
      chat.channels.add(channel)
      channel.sendMessage("Welcome X! You are talking with: \n")
      closureScope:
        let channel = channel
        proc channelDisconnected(future: Future[void]) =
          chat.channels.delete(chat.channels.find(channel))
          chat.publish(message = "X left\n")
        processClientMessages(channel, chat).addCallback(channelDisconnected)

proc main() =
  var server, port, configfile: string
  var optParser = initOptParser()
  for kind, key, value in optParser.getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      case key
      of "config", "c": configfile = value
      of "server", "s": server = value
      of "port", "p": port = value
    else:
      assert(false)
  var gnunetApp = initGnunetApplication(configfile)
  asyncCheck firstTask(gnunetApp, server, port)
  try:
    while true:
      poll(gnunetApp.millisecondsUntilTimeout())
      gnunetApp.doWork()
  except ValueError:
    echo "quitting"

main()
GC_fullCollect()
