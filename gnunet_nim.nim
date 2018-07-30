import gnunet_application
import asyncdispatch
import asynccadet

proc firstTask(gnunetApp: ref GnunetApplication) {.async.} =
  echo "connecting Cadet"
  var cadet = await gnunetApp.connectCadet()
  echo "connected"
  let port = cadet.openPort("test")
  echo "port opened"
  let (finished, channel) = await port.channels.read()
  echo "incoming connection!"
  if not finished:
    let (finished, message) = await channel.messages.read()
    if not finished:
      echo "got message: ", message
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
