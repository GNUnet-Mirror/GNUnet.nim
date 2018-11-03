import gnunet_scheduler_lib
import gnunet_configuration_lib
import gnunet_time_lib
import gnunet_types
import asyncdispatch, tables, logging

type
  GnunetApplication* = object
    timeoutUs*: uint64
    tasks*: Table[ptr GNUNET_SCHEDULER_Task, ptr GNUNET_SCHEDULER_FdInfo]
    schedulerDriver*: GNUNET_SCHEDULER_Driver
    schedulerHandle*: ptr GNUNET_SCHEDULER_Handle
    configHandle*: ptr GNUNET_CONFIGURATION_Handle
    connectFutures*: Table[string, FutureBase]

proc schedulerAdd*(cls: pointer,
                   task: ptr GNUNET_SCHEDULER_Task,
                   fdi: ptr GNUNET_SCHEDULER_FdInfo): cint {.cdecl.} =
  ## callback allowing GNUnet to add a file descriptor to the event loop
  type AddProc = proc(fd: AsyncFD, cb: proc(fd: AsyncFD): bool)
  let app = cast[ptr GnunetApplication](cls)
  debug("adding fd ", fdi.sock)
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
  let addReadResult =
    addByInterest(GNUNET_SCHEDULER_EventType.GNUNET_SCHEDULER_ET_IN, addRead)
  let addWriteResult =
    addByInterest(GNUNET_SCHEDULER_EventType.GNUNET_SCHEDULER_ET_OUT, addWrite)
  debug("added read fd: ", addReadResult, ", added write fd: ", addWriteResult)
  if addReadResult or addWriteResult:
    app.tasks.add(task, fdi)
    return GNUNET_OK
  error("Cannot add file descriptor because the event type is not supported")
  return GNUNET_SYSERR

proc schedulerDelete*(cls: pointer,
                      task: ptr GNUNET_SCHEDULER_Task): cint {.cdecl.} =
  ## callback allowing GNUnet to delete a file descriptor from the event loop
  let app = cast[ptr GnunetApplication](cls)
  var fdi: ptr GNUNET_SCHEDULER_FdInfo
  if app.tasks.take(task, fdi):
    for v in app.tasks.values():
      if v.sock == fdi.sock:
        return GNUNET_OK
    unregister(AsyncFD(fdi.sock))
    return GNUNET_OK
  echo("Cannot remove file descriptor because it has not been added or is already gone")
  return GNUNET_SYSERR

proc schedulerSetWakeup*(cls: pointer,
                         dt: GNUNET_TIME_Absolute) {.cdecl.} =
  ## callback allowing GNUnet to set a new wakeup time
  let app = cast[ptr GnunetApplication](cls)
  debug("setting new timeout: ", dt.abs_value_us)
  app.timeoutUs = dt.abs_value_us
