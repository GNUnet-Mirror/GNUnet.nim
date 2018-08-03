import gnunet_application
import asyncdispatch
import asynccadet

proc firstTask(gnunetApp: ref GnunetApplication) {.async.} =
  echo "connecting Cadet"
  var cadet = await gnunetApp.connectCadet()
  echo "connected"
  let port = cadet.openPort("test")
  echo "port opened"
  let (hasChannel, channel) = await port.channels.read()
  if hasChannel:
    echo "incoming connection!"
    while true:
      let (hasData, message) = await channel.messages.read()
      if not hasData:
        break;
      echo "got message: ", message
  #while true:
  #  echo "reading future"
  #  let (hasChannel, channel) = await port.channels.read()
  #  if not hasChannel:
  #    break
  #  echo "incoming connection!"
  #  while true:
  #    let (hasData, message) = await channel.messages.read()
  #    echo "message?"
  #    if not hasData:
  #      break;
  #    echo "got message: ", message
  echo "disconnecting"
  cadet.disconnect()
  echo "disconnected"

proc main() =
  var gnunetApp = initGnunetApplication("gnunet.conf")
  asyncCheck firstTask(gnunetApp)
  try:
    while true:
      echo "polling, timeout = ", gnunetApp.millisecondsUntilTimeout()
      poll(gnunetApp.millisecondsUntilTimeout())
      gnunetApp.doWork()
  except ValueError:
    echo "quitting"

main()
GC_fullCollect()
