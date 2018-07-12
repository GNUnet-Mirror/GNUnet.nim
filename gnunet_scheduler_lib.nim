 {.deadCodeElim: on.}
when defined(windows):
  const
    libname* = "libgnunetutil.dll"
elif defined(macosx):
  const
    libname* = "libgnunetutil.dylib"
else:
  const
    libname* = "libgnunetutil.so"


type
  GNUNET_SCHEDULER_Task* {.bycopy.} = object
  


type
  GNUNET_SCHEDULER_Reason* {.size: sizeof(cint).} = enum
    GNUNET_SCHEDULER_REASON_NONE = 0, GNUNET_SCHEDULER_REASON_STARTUP = 1,
    GNUNET_SCHEDULER_REASON_SHUTDOWN = 2, GNUNET_SCHEDULER_REASON_TIMEOUT = 4,
    GNUNET_SCHEDULER_REASON_READ_READY = 8,
    GNUNET_SCHEDULER_REASON_WRITE_READY = 16,
    GNUNET_SCHEDULER_REASON_PREREQ_DONE = 32


import
  gnunet_types, gnunet_time_lib


type
  GNUNET_SCHEDULER_EventType* {.size: sizeof(cint).} = enum
    GNUNET_SCHEDULER_ET_NONE = 0, GNUNET_SCHEDULER_ET_IN = 1,
    GNUNET_SCHEDULER_ET_OUT = 2, GNUNET_SCHEDULER_ET_HUP = 4,
    GNUNET_SCHEDULER_ET_ERR = 8, GNUNET_SCHEDULER_ET_PRI = 16,
    GNUNET_SCHEDULER_ET_NVAL = 32



type
  GNUNET_SCHEDULER_FdInfo* {.bycopy.} = object
    fd*: ptr GNUNET_NETWORK_Handle
    fh*: ptr GNUNET_DISK_FileHandle
    et*: GNUNET_SCHEDULER_EventType
    sock*: cint



proc GNUNET_SCHEDULER_task_ready*(task: ptr GNUNET_SCHEDULER_Task;
                                 fdi: ptr GNUNET_SCHEDULER_FdInfo) {.cdecl,
    importc: "GNUNET_SCHEDULER_task_ready", dynlib: libname.}

type
  GNUNET_SCHEDULER_Handle* {.bycopy.} = object
  


proc GNUNET_SCHEDULER_do_work*(sh: ptr GNUNET_SCHEDULER_Handle): cint {.cdecl,
    importc: "GNUNET_SCHEDULER_do_work", dynlib: libname.}

type
  GNUNET_SCHEDULER_Driver* {.bycopy.} = object
    cls*: pointer
    add*: proc (cls: pointer; task: ptr GNUNET_SCHEDULER_Task;
              fdi: ptr GNUNET_SCHEDULER_FdInfo): cint {.cdecl.}
    del*: proc (cls: pointer; task: ptr GNUNET_SCHEDULER_Task): cint {.cdecl.}
    set_wakeup*: proc (cls: pointer; dt: GNUNET_TIME_Absolute) {.cdecl.}



type
  GNUNET_SCHEDULER_TaskCallback* = proc (cls: pointer) {.cdecl.}


proc GNUNET_SCHEDULER_driver_init*(driver: ptr GNUNET_SCHEDULER_Driver): ptr GNUNET_SCHEDULER_Handle {.
    cdecl, importc: "GNUNET_SCHEDULER_driver_init", dynlib: libname.}

proc GNUNET_SCHEDULER_driver_done*(sh: ptr GNUNET_SCHEDULER_Handle) {.cdecl,
    importc: "GNUNET_SCHEDULER_driver_done", dynlib: libname.}

proc GNUNET_SCHEDULER_shutdown*() {.cdecl, importc: "GNUNET_SCHEDULER_shutdown",
                                  dynlib: libname.}

