import ../gnunet_application, ../asynccadet, ../gnunet_utils
import asyncdispatch, asyncfile, parseopt, strutils, sequtils, times, os

type Chat = object
  channels: seq[ref CadetChannel]

proc publish(chat: ref Chat, message: string, sender: ref CadetChannel = nil) =
  let message =
    if sender.isNil(): message.strip(leading = false)
    else: "[" & sender.peer.peerId() & "] " & message.strip(leading = false)
  echo getDatestr(), " ", getClockStr(), " ", message
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
  while true:
    let (hasData, message) = await channel.messages.read()
    if not hasData:
      shutdownGnunetApplication()
      return
    echo getDateStr()," ",getClockStr()," ",message

proc processInput(inputFile: AsyncFile, channel: ref CadetChannel) {.async.} =
  while true:
    let input = await inputFile.readline()
    channel.sendMessage(input)

proc firstTask(gnunetApp: ref GnunetApplication,
               server: string,
               port: string) {.async.} =
  let cadet = await gnunetApp.initCadet()
  var chat = new(Chat)
  chat.channels = newSeq[ref CadetChannel]()
  if not server.isNil():
    let inputFile = openAsync("/dev/stdin", fmRead)
    let channel = cadet.createChannel(server, port)
    await processServerMessages(channel) or processInput(inputFile, channel)
    inputFile.close()
  else:
    let cadetPort = cadet.openPort(port)
    while true:
      let (hasChannel, channel) = await cadetPort.channels.read()
      if not hasChannel:
        break
      let peerId = channel.peer.peerId()
      chat.publish(message = peerId & " joined\n")
      let listParticipants =
        chat.channels.map(proc(c: ref CadetChannel): string = c.peer.peerId)
      channel.sendMessage("Welcome " & peerId & "! participants: " & $listParticipants)
      chat.channels.add(channel)
      closureScope:
        let channel = channel
        let peerId = peerId
        proc channelDisconnected(future: Future[void]) =
          chat.channels.delete(chat.channels.find(channel))
          chat.publish(message = peerId & " left\n")
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
  if configfile.isNil():
    echo "I need a config file to use."
    echo "  Add -c=<gnunet.conf>"
    return
  if port.isNil():
    echo "I need a shared secret port to use."
    echo "  Add -p=<sharedsecret>"
    return
  if server.isNil():
    echo "Entering server mode."
  var gnunetApp = initGnunetApplication(configfile)
  asyncCheck firstTask(gnunetApp, server, port)
  while hasPendingOperations():
    poll(gnunetApp.millisecondsUntilTimeout())
    gnunetApp.doWork()
  echo "Quitting."

main()
GC_fullCollect()
