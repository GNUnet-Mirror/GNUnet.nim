import gnunet_application
import asyncdispatch
import asynccadet

proc firstTask(gnunetApp: ref GnunetApplication) {.async.} =
  echo "connecting Cadet"
  var cadet = await gnunetApp.connectCadet()
  echo "connected"
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
    discard
  gnunetApp.cleanup()
  echo "quitting"

main()
