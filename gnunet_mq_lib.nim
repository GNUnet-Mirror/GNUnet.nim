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


import gnunet_types, gnunet_scheduler_lib, gnunet_configuration_lib


type
  GNUNET_MQ_Envelope* {.bycopy.} = object
  


proc GNUNET_MQ_env_get_msg*(env: ptr GNUNET_MQ_Envelope): ptr GNUNET_MessageHeader {.
    cdecl, importc: "GNUNET_MQ_env_get_msg", dynlib: libname.}

proc GNUNET_MQ_env_next*(env: ptr GNUNET_MQ_Envelope): ptr GNUNET_MQ_Envelope {.cdecl,
    importc: "GNUNET_MQ_env_next", dynlib: libname.}

type
  GNUNET_MQ_Handle* {.bycopy.} = object
  


type
  GNUNET_MQ_Error* {.size: sizeof(cint).} = enum
    GNUNET_MQ_ERROR_READ = 1, GNUNET_MQ_ERROR_WRITE = 2, GNUNET_MQ_ERROR_TIMEOUT = 4,
    GNUNET_MQ_ERROR_MALFORMED = 8, GNUNET_MQ_ERROR_NO_MATCH = 16



type
  GNUNET_MQ_MessageCallback* = proc (cls: pointer; msg: ptr GNUNET_MessageHeader) {.
      cdecl.}


type
  GNUNET_MQ_MessageValidationCallback* = proc (cls: pointer;
      msg: ptr GNUNET_MessageHeader): cint {.cdecl.}


type
  GNUNET_MQ_SendImpl* = proc (mq: ptr GNUNET_MQ_Handle; msg: ptr GNUNET_MessageHeader;
                           impl_state: pointer) {.cdecl.}


type
  GNUNET_MQ_DestroyImpl* = proc (mq: ptr GNUNET_MQ_Handle; impl_state: pointer) {.cdecl.}


type
  GNUNET_MQ_CancelImpl* = proc (mq: ptr GNUNET_MQ_Handle; impl_state: pointer) {.cdecl.}


type
  GNUNET_MQ_ErrorHandler* = proc (cls: pointer; error: GNUNET_MQ_Error) {.cdecl.}


proc GNUNET_MQ_dll_insert_tail*(env_head: ptr ptr GNUNET_MQ_Envelope;
                               env_tail: ptr ptr GNUNET_MQ_Envelope;
                               env: ptr GNUNET_MQ_Envelope) {.cdecl,
    importc: "GNUNET_MQ_dll_insert_tail", dynlib: libname.}

proc GNUNET_MQ_dll_remove*(env_head: ptr ptr GNUNET_MQ_Envelope;
                          env_tail: ptr ptr GNUNET_MQ_Envelope;
                          env: ptr GNUNET_MQ_Envelope) {.cdecl,
    importc: "GNUNET_MQ_dll_remove", dynlib: libname.}

type
  GNUNET_MQ_MessageHandler* {.bycopy.} = object
    mv*: GNUNET_MQ_MessageValidationCallback
    cb*: GNUNET_MQ_MessageCallback
    cls*: pointer
    `type`*: uint16
    expected_size*: uint16

proc GNUNET_MQ_copy_handlers*(handlers: ptr GNUNET_MQ_MessageHandler): ptr GNUNET_MQ_MessageHandler {.
    cdecl, importc: "GNUNET_MQ_copy_handlers", dynlib: libname.}

proc GNUNET_MQ_copy_handlers2*(handlers: ptr GNUNET_MQ_MessageHandler;
                              agpl_handler: GNUNET_MQ_MessageCallback;
                              agpl_cls: pointer): ptr GNUNET_MQ_MessageHandler {.
    cdecl, importc: "GNUNET_MQ_copy_handlers2", dynlib: libname.}

proc GNUNET_MQ_count_handlers*(handlers: ptr GNUNET_MQ_MessageHandler): cuint {.
    cdecl, importc: "GNUNET_MQ_count_handlers", dynlib: libname.}

proc GNUNET_MQ_msg_copy*(hdr: ptr GNUNET_MessageHeader): ptr GNUNET_MQ_Envelope {.
    cdecl, importc: "GNUNET_MQ_msg_copy", dynlib: libname.}

proc GNUNET_MQ_discard*(mqm: ptr GNUNET_MQ_Envelope) {.cdecl,
    importc: "GNUNET_MQ_discard", dynlib: libname.}

proc GNUNET_MQ_get_current_envelope*(mq: ptr GNUNET_MQ_Handle): ptr GNUNET_MQ_Envelope {.
    cdecl, importc: "GNUNET_MQ_get_current_envelope", dynlib: libname.}

proc GNUNET_MQ_env_copy*(env: ptr GNUNET_MQ_Envelope): ptr GNUNET_MQ_Envelope {.cdecl,
    importc: "GNUNET_MQ_env_copy", dynlib: libname.}

proc GNUNET_MQ_get_last_envelope*(mq: ptr GNUNET_MQ_Handle): ptr GNUNET_MQ_Envelope {.
    cdecl, importc: "GNUNET_MQ_get_last_envelope", dynlib: libname.}

proc GNUNET_MQ_env_set_options*(env: ptr GNUNET_MQ_Envelope; flags: uint64;
                               extra: pointer) {.cdecl,
    importc: "GNUNET_MQ_env_set_options", dynlib: libname.}

proc GNUNET_MQ_env_get_options*(env: ptr GNUNET_MQ_Envelope; flags: ptr uint64): pointer {.
    cdecl, importc: "GNUNET_MQ_env_get_options", dynlib: libname.}

proc GNUNET_MQ_unsent_head*(mq: ptr GNUNET_MQ_Handle): ptr GNUNET_MQ_Envelope {.cdecl,
    importc: "GNUNET_MQ_unsent_head", dynlib: libname.}

proc GNUNET_MQ_set_options*(mq: ptr GNUNET_MQ_Handle; flags: uint64; extra: pointer) {.
    cdecl, importc: "GNUNET_MQ_set_options", dynlib: libname.}

proc GNUNET_MQ_get_length*(mq: ptr GNUNET_MQ_Handle): cuint {.cdecl,
    importc: "GNUNET_MQ_get_length", dynlib: libname.}

proc GNUNET_MQ_send*(mq: ptr GNUNET_MQ_Handle; ev: ptr GNUNET_MQ_Envelope) {.cdecl,
    importc: "GNUNET_MQ_send", dynlib: libname.}

proc GNUNET_MQ_send_copy*(mq: ptr GNUNET_MQ_Handle; ev: ptr GNUNET_MQ_Envelope) {.
    cdecl, importc: "GNUNET_MQ_send_copy", dynlib: libname.}

proc GNUNET_MQ_send_cancel*(ev: ptr GNUNET_MQ_Envelope) {.cdecl,
    importc: "GNUNET_MQ_send_cancel", dynlib: libname.}

proc GNUNET_MQ_assoc_add*(mq: ptr GNUNET_MQ_Handle; assoc_data: pointer): uint32 {.
    cdecl, importc: "GNUNET_MQ_assoc_add", dynlib: libname.}

proc GNUNET_MQ_assoc_get*(mq: ptr GNUNET_MQ_Handle; request_id: uint32): pointer {.
    cdecl, importc: "GNUNET_MQ_assoc_get", dynlib: libname.}

proc GNUNET_MQ_assoc_remove*(mq: ptr GNUNET_MQ_Handle; request_id: uint32): pointer {.
    cdecl, importc: "GNUNET_MQ_assoc_remove", dynlib: libname.}

proc GNUNET_MQ_notify_sent*(ev: ptr GNUNET_MQ_Envelope;
                           cb: GNUNET_SCHEDULER_TaskCallback; cb_cls: pointer) {.
    cdecl, importc: "GNUNET_MQ_notify_sent", dynlib: libname.}

proc GNUNET_MQ_destroy*(mq: ptr GNUNET_MQ_Handle) {.cdecl,
    importc: "GNUNET_MQ_destroy", dynlib: libname.}

type
  GNUNET_MQ_DestroyNotificationHandle* {.bycopy.} = object
  


proc GNUNET_MQ_destroy_notify*(mq: ptr GNUNET_MQ_Handle;
                              cb: GNUNET_SCHEDULER_TaskCallback; cb_cls: pointer): ptr GNUNET_MQ_DestroyNotificationHandle {.
    cdecl, importc: "GNUNET_MQ_destroy_notify", dynlib: libname.}

proc GNUNET_MQ_destroy_notify_cancel*(dnh: ptr GNUNET_MQ_DestroyNotificationHandle) {.
    cdecl, importc: "GNUNET_MQ_destroy_notify_cancel", dynlib: libname.}

proc GNUNET_MQ_inject_message*(mq: ptr GNUNET_MQ_Handle;
                              mh: ptr GNUNET_MessageHeader) {.cdecl,
    importc: "GNUNET_MQ_inject_message", dynlib: libname.}

proc GNUNET_MQ_inject_error*(mq: ptr GNUNET_MQ_Handle; error: GNUNET_MQ_Error) {.
    cdecl, importc: "GNUNET_MQ_inject_error", dynlib: libname.}

proc GNUNET_MQ_impl_send_continue*(mq: ptr GNUNET_MQ_Handle) {.cdecl,
    importc: "GNUNET_MQ_impl_send_continue", dynlib: libname.}

proc GNUNET_MQ_impl_send_in_flight*(mq: ptr GNUNET_MQ_Handle) {.cdecl,
    importc: "GNUNET_MQ_impl_send_in_flight", dynlib: libname.}

proc GNUNET_MQ_impl_state*(mq: ptr GNUNET_MQ_Handle): pointer {.cdecl,
    importc: "GNUNET_MQ_impl_state", dynlib: libname.}

proc GNUNET_MQ_impl_current*(mq: ptr GNUNET_MQ_Handle): ptr GNUNET_MessageHeader {.
    cdecl, importc: "GNUNET_MQ_impl_current", dynlib: libname.}
