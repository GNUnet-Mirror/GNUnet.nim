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
  app.timeoutUs = dt.abs_value_us

proc initGnunetApplication*(configFile: string): GnunetApplication =
  result.timeoutUs = GNUNET_TIME_absolute_get_forever().abs_value_us
  result.tasks = initTable[ptr GNUNET_SCHEDULER_Task, ptr GNUNET_SCHEDULER_FdInfo]()
  result.schedulerDriver = GNUNET_SCHEDULER_Driver(cls: addr result,
                                                   add: schedulerAdd,
                                                   del: schedulerDelete,
                                                   set_wakeup: schedulerSetWakeup)
  result.schedulerHandle = GNUNET_SCHEDULER_driver_init(addr result.schedulerDriver)
  result.configHandle = GNUNET_CONFIGURATION_create()
  assert(GNUNET_SYSERR != GNUNET_CONFIGURATION_load(result.configHandle, configFile))

proc cleanup*(app: GnunetApplication) =
  GNUNET_SCHEDULER_driver_done(app.schedulerHandle)
  GNUNET_CONFIGURATION_destroy(app.configHandle)

proc doWork*(app: GnunetApplication) =
  discard GNUNET_SCHEDULER_do_work(app.schedulerHandle) #FIXME

proc microsecondsUntilTimeout*(app: GnunetApplication): int =
  ## get the duration until timeout in microseconds
  let now = GNUNET_TIME_absolute_get()
  if app.timeoutUs < now.abs_value_us:
    return 0
  return int(app.timeoutUs - now.abs_value_us)

proc millisecondsUntilTimeout*(app: GnunetApplication): int =
  ## get the duration until timeout in milliseconds
  return app.microsecondsUntilTimeout() div 1_000
