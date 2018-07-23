import gnunet_application
import asyncdispatch
import asynccadet

proc firstTask(gnunetApp: GnunetApplication) {.async.} =
  let cadet = await gnunetApp.connectCadet()
  echo "hello"

proc main() =
  var gnunetApp = initGnunetApplication("~/.gnunet/gnunet.conf")
  asyncCheck firstTask(gnunetApp)
  try:
    while true:
      poll(gnunetApp.millisecondsUntilTimeout())
      gnunetApp.doWork()
  except ValueError:
    discard
  gnunetApp.cleanup()
  echo "quitting"

main()
