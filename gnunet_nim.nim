import gnunet_application
import asyncdispatch
import asynccadet

proc main() =
  var gnunetApp = initGnunetApplication("~/.gnunet/gnunet.conf")
  var cadet = gnunetApp.connectCadet()
  try:
    while true:
      poll(gnunetApp.millisecondsUntilTimeout())
      gnunetApp.doWork()
  except ValueError:
    discard
  gnunetApp.cleanup()
  echo "quitting"

main()
