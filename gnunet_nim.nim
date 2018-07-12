import gnunet_types
import gnunet_scheduler_lib
import gnunet_time_lib
import gnunet_configuration_lib
import asyncdispatch
import asynccadet
import logging
import tables

type Scheduler = object
  timeoutUs: uint64
  gnunetTasks: Table[ptr GNUNET_SCHEDULER_Task, ptr GNUNET_SCHEDULER_FdInfo]

proc microsecondsUntilTimeout(scheduler: Scheduler): int =
  ## get the duration until timeout in microseconds
  let now = GNUNET_TIME_absolute_get()
  if scheduler.timeoutUs < now.abs_value_us:
    return 0
  return int(scheduler.timeoutUs - now.abs_value_us)

proc millisecondsUntilTimeout(scheduler: Scheduler): int =
  ## get the duration until timeout in milliseconds
  return scheduler.microsecondsUntilTimeout() div 1_000

proc schedulerAdd(cls: pointer,
                  task: ptr GNUNET_SCHEDULER_Task,
                  fdi: ptr GNUNET_SCHEDULER_FdInfo): cint {.cdecl.} =
  ## callback allowing GNUnet to add a file descriptor to the event loop
  type AddProc = proc(fd: AsyncFD, cb: proc(fd: AsyncFD): bool)
  var scheduler = cast[ptr Scheduler](cls)
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
    scheduler.gnunetTasks.add(task, fdi)
    return GNUNET_OK
  error("Cannot add file descriptor because the event type is not supported")
  return GNUNET_SYSERR

proc schedulerDelete(cls: pointer,
                     task: ptr GNUNET_SCHEDULER_Task): cint {.cdecl.} =
  ## callback allowing GNUnet to delete a file descriptor from the event loop
  var scheduler = cast[ptr Scheduler](cls)
  var fdi: ptr GNUNET_SCHEDULER_FdInfo
  if scheduler.gnunetTasks.take(task, fdi):
    unregister(AsyncFD(fdi.sock))
    return GNUNET_OK
  error("Cannot remove file descriptor because it has not been added or is already gone")
  return GNUNET_SYSERR

proc schedulerSetWakeup(cls: pointer,
                        dt: GNUNET_TIME_Absolute) {.cdecl.} =
  ## callback allowing GNUnet to set a new wakeup time
  var scheduler = cast[ptr Scheduler](cls)
  scheduler.timeoutUs = dt.abs_value_us

proc main() =
  var scheduler = Scheduler(
    timeoutUs: GNUNET_TIME_absolute_get_forever().abs_value_us,
    gnunetTasks: initTable[ptr GNUNET_SCHEDULER_Task, ptr GNUNET_SCHEDULER_FdInfo]()
  )
  var configHandle = GNUNET_CONFIGURATION_create()
  assert(GNUNET_SYSERR != GNUNET_CONFIGURATION_load(configHandle, "gnunet.conf"))
  var driver = GNUNET_SCHEDULER_Driver(cls: addr scheduler,
                                       add: schedulerAdd,
                                       del: schedulerDelete,
                                       set_wakeup: schedulerSetWakeup)
  let schedulerHandle = GNUNET_SCHEDULER_driver_init(addr driver)
  try:
    while true:
      poll(scheduler.millisecondsUntilTimeout())
      var work_result = GNUNET_SCHEDULER_do_work(schedulerHandle)
      echo "work_result: ", work_result
  except ValueError:
    discard
  GNUNET_SCHEDULER_driver_done(schedulerHandle)
  GNUNET_CONFIGURATION_destroy(configHandle)
  echo "quitting"

main()
