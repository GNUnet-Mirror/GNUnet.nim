import gnunet_nim/gnunet_types
import gnunet_nim/gnunet_scheduler_lib
import gnunet_nim/gnunet_time_lib
import gnunet_nim/gnunet_configuration_lib
import gnunet_nim/gnunet_crypto_lib
import gnunet_nim/gnunet_common
import gnunet_nim/scheduler
import asyncdispatch, tables, logging

export GnunetApplication

proc peerId*(peer: GNUNET_PeerIdentity): string =
  let peerId = GNUNET_i2s(unsafeAddr peer)
  let peerIdLen = peerId.len()
  result = newString(peerIdLen)
  copyMem(addr result[0], peerId, peerIdLen)

proc fullPeerId*(peer: GNUNET_PeerIdentity): string =
  let peerId = GNUNET_i2s_full(unsafeAddr peer)
  let peerIdLen = peerId.len()
  result = newString(peerIdLen)
  copyMem(addr result[0], peerId, peerIdLen)

proc initGnunetApplication*(configFile: string): ref GnunetApplication =
  var app: ref GnunetApplication
  proc cleanup(app: ref GnunetApplication) =
    echo "destroying GnunetApplication"
    GNUNET_SCHEDULER_driver_done(app.schedulerHandle)
    GNUNET_CONFIGURATION_destroy(app.configHandle)
  new(app, cleanup)
  app.timeoutUs = GNUNET_TIME_absolute_get_forever().abs_value_us
  app.tasks = initTable[ptr GNUNET_SCHEDULER_Task, ptr GNUNET_SCHEDULER_FdInfo]()
  app.schedulerDriver = GNUNET_SCHEDULER_Driver(cls: addr app[],
                                                add: schedulerAdd,
                                                del: schedulerDelete,
                                                set_wakeup: schedulerSetWakeup)
  app.schedulerHandle = GNUNET_SCHEDULER_driver_init(addr app.schedulerDriver)
  app.configHandle = GNUNET_CONFIGURATION_create()
  app.connectFutures = initTable[string, FutureBase]()
  let loadResult = GNUNET_CONFIGURATION_load(app.configHandle, configFile)
  assert(GNUNET_SYSERR != loadResult)
  return app

proc shutdownGnunetApplication*() =
  GNUNET_SCHEDULER_shutdown()

proc doWork*(app: ref GnunetApplication) =
  discard GNUNET_SCHEDULER_do_work(app.schedulerHandle) #FIXME: don't discard

proc microsecondsUntilTimeout*(app: ref GnunetApplication): int =
  ## get the duration until timeout in microseconds
  let now = GNUNET_TIME_absolute_get()
  if app.timeoutUs < now.abs_value_us:
    return 0
  elif app.timeoutUs == 0xff_ff_ff_ff_ff_ff_ff_ff'u64: # high(uint64) not implemented
    return -1
  return int(min(app.timeoutUs - now.abs_value_us, uint64(high(cint))))

proc millisecondsUntilTimeout*(app: ref GnunetApplication): int =
  ## get the duration until timeout in milliseconds
  let timeoutUs = app.microsecondsUntilTimeout()
  if timeoutUs < 0:
    return -1
  return timeoutUs div 1_000
