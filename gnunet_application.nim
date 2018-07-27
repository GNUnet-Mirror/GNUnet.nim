import gnunet_types
import gnunet_scheduler_lib
import gnunet_time_lib
import gnunet_configuration_lib
import asyncdispatch, tables, logging

type
  GnunetApplication* = object
    timeoutUs: uint64
    tasks: Table[ptr GNUNET_SCHEDULER_Task, ptr GNUNET_SCHEDULER_FdInfo]
    schedulerDriver: GNUNET_SCHEDULER_Driver
    schedulerHandle: ptr GNUNET_SCHEDULER_Handle
    configHandle*: ptr GNUNET_CONFIGURATION_Handle

proc schedulerAdd(cls: pointer,
                  task: ptr GNUNET_SCHEDULER_Task,
                  fdi: ptr GNUNET_SCHEDULER_FdInfo): cint {.cdecl.} =
  ## callback allowing GNUnet to add a file descriptor to the event loop
  type AddProc = proc(fd: AsyncFD, cb: proc(fd: AsyncFD): bool)
  var app = cast[ptr GnunetApplication](cls)
  let fd = AsyncFD(fdi.sock)
  proc addByInterest(interest: GNUNET_SCHEDULER_EventType, addProc: AddProc) : bool =
    result = false
    if (cast[int](fdi.et) and cast[int](interest)) != 0:
      result = true
      if not getGlobalDispatcher().contains(fd):
        register(fd)
      proc callback(fd: AsyncFD): bool =
        result = true
        fdi.et = interest
        GNUNET_SCHEDULER_task_ready(task, fdi)
      addProc(fd, callback)
  if addByInterest(GNUNET_SCHEDULER_EventType.GNUNET_SCHEDULER_ET_IN, addRead) or
     addByInterest(GNUNET_SCHEDULER_EventType.GNUNET_SCHEDULER_ET_OUT, addWrite):
    app.tasks.add(task, fdi)
    return GNUNET_OK
  error("Cannot add file descriptor because the event type is not supported")
  return GNUNET_SYSERR

proc schedulerDelete(cls: pointer,
                     task: ptr GNUNET_SCHEDULER_Task): cint {.cdecl.} =
  ## callback allowing GNUnet to delete a file descriptor from the event loop
  var app = cast[ptr GnunetApplication](cls)
  var fdi: ptr GNUNET_SCHEDULER_FdInfo
  if app.tasks.take(task, fdi):
    unregister(AsyncFD(fdi.sock))
    return GNUNET_OK
  error("Cannot remove file descriptor because it has not been added or is already gone")
  return GNUNET_SYSERR

proc schedulerSetWakeup(cls: pointer,
                        dt: GNUNET_TIME_Absolute) {.cdecl.} =
  ## callback allowing GNUnet to set a new wakeup time
  var app = cast[ptr GnunetApplication](cls)
  debug("setting new timeout: ", dt.abs_value_us)
  app.timeoutUs = dt.abs_value_us

proc initGnunetApplication*(configFile: string): ref GnunetApplication =
  var app: ref GnunetApplication
  new(app)
  app.timeoutUs = GNUNET_TIME_absolute_get_forever().abs_value_us
  app.tasks = initTable[ptr GNUNET_SCHEDULER_Task, ptr GNUNET_SCHEDULER_FdInfo]()
  app.schedulerDriver = GNUNET_SCHEDULER_Driver(cls: addr app[],
                                                add: schedulerAdd,
                                                del: schedulerDelete,
                                                set_wakeup: schedulerSetWakeup)
  app.schedulerHandle = GNUNET_SCHEDULER_driver_init(addr app.schedulerDriver)
  app.configHandle = GNUNET_CONFIGURATION_create()
  assert(GNUNET_SYSERR != GNUNET_CONFIGURATION_load(app.configHandle, configFile))
  return app

proc cleanup*(app: ref GnunetApplication) =
  GNUNET_SCHEDULER_driver_done(app.schedulerHandle)
  GNUNET_CONFIGURATION_destroy(app.configHandle)

proc doWork*(app: ref GnunetApplication) =
  discard GNUNET_SCHEDULER_do_work(app.schedulerHandle) #FIXME: don't discard

proc microsecondsUntilTimeout*(app: ref GnunetApplication): int =
  ## get the duration until timeout in microseconds
  let now = GNUNET_TIME_absolute_get()
  if app.timeoutUs < now.abs_value_us:
    debug("app.timeoutUs = ", app.timeoutUs, ", now = ", now.abs_value_us)
    return 0
  elif app.timeoutUs == 0xff_ff_ff_ff_ff_ff_ff_ff'u64:
    return -1
  return int(min(app.timeoutUs - now.abs_value_us, uint64(high(cint))))

proc millisecondsUntilTimeout*(app: ref GnunetApplication): int =
  ## get the duration until timeout in milliseconds
  let timeoutUs = app.microsecondsUntilTimeout()
  if timeoutUs < 0:
    return -1
  return timeoutUs div 1_000
