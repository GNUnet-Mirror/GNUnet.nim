 {.deadCodeElim: on.}
when defined(windows):
  const
    libname* = "libgnunetcadet.dll"
elif defined(macosx):
  const
    libname* = "libgnunetcadet.dylib"
else:
  const
    libname* = "libgnunetcadet.so"


import gnunet_crypto_lib, gnunet_types

type
  GNUNET_FileNameCallback* = proc (cls: pointer; filename: cstring): cint {.cdecl.}


type
  GNUNET_ContinuationCallback* = proc (cls: pointer) {.cdecl.}


type
  GNUNET_ResultCallback* = proc (cls: pointer; result_code: int64; data: pointer;
                              data_size: uint16) {.cdecl.}


type
  GNUNET_ErrorType* {.size: sizeof(cint).} = enum
    GNUNET_ERROR_TYPE_UNSPECIFIED = -1, GNUNET_ERROR_TYPE_NONE = 0,
    GNUNET_ERROR_TYPE_ERROR = 1, GNUNET_ERROR_TYPE_WARNING = 2,
    GNUNET_ERROR_TYPE_MESSAGE = 4, GNUNET_ERROR_TYPE_INFO = 8,
    GNUNET_ERROR_TYPE_DEBUG = 16, GNUNET_ERROR_TYPE_INVALID = 32,
    GNUNET_ERROR_TYPE_BULK = 64



type
  GNUNET_Logger* = proc (cls: pointer; kind: GNUNET_ErrorType; component: cstring;
                      date: cstring; message: cstring) {.cdecl.}


proc GNUNET_get_log_skip*(): cint {.cdecl, importc: "GNUNET_get_log_skip",
                                 dynlib: libname.}
when not defined(GNUNET_CULL_LOGGING):
  proc GNUNET_get_log_call_status*(caller_level: cint; comp: cstring; file: cstring;
                                  function: cstring; line: cint): cint {.cdecl,
      importc: "GNUNET_get_log_call_status", dynlib: libname.}

proc GNUNET_log_from_nocheck*(kind: GNUNET_ErrorType; comp: cstring; message: cstring) {.
    varargs, cdecl, importc: "GNUNET_log_from_nocheck", dynlib: libname.}

proc GNUNET_log_config_missing*(kind: GNUNET_ErrorType; section: cstring;
                               option: cstring) {.cdecl,
    importc: "GNUNET_log_config_missing", dynlib: libname.}

proc GNUNET_log_config_invalid*(kind: GNUNET_ErrorType; section: cstring;
                               option: cstring; required: cstring) {.cdecl,
    importc: "GNUNET_log_config_invalid", dynlib: libname.}

proc GNUNET_log_skip*(n: cint; check_reset: cint) {.cdecl, importc: "GNUNET_log_skip",
    dynlib: libname.}

proc GNUNET_log_setup*(comp: cstring; loglevel: cstring; logfile: cstring): cint {.
    cdecl, importc: "GNUNET_log_setup", dynlib: libname.}

proc GNUNET_logger_add*(logger: GNUNET_Logger; logger_cls: pointer) {.cdecl,
    importc: "GNUNET_logger_add", dynlib: libname.}

proc GNUNET_logger_remove*(logger: GNUNET_Logger; logger_cls: pointer) {.cdecl,
    importc: "GNUNET_logger_remove", dynlib: libname.}

proc GNUNET_sh2s*(shc: ptr GNUNET_ShortHashCode): cstring {.cdecl,
    importc: "GNUNET_sh2s", dynlib: libname.}

proc GNUNET_h2s*(hc: ptr GNUNET_HashCode): cstring {.cdecl, importc: "GNUNET_h2s",
    dynlib: libname.}

proc GNUNET_h2s2*(hc: ptr GNUNET_HashCode): cstring {.cdecl, importc: "GNUNET_h2s2",
    dynlib: libname.}

proc GNUNET_h2s_full*(hc: ptr GNUNET_HashCode): cstring {.cdecl,
    importc: "GNUNET_h2s_full", dynlib: libname.}

type
  GNUNET_CRYPTO_EddsaPublicKey* {.bycopy.} = object
  


type
  GNUNET_CRYPTO_EcdhePublicKey* {.bycopy.} = object
  


proc GNUNET_p2s*(p: ptr GNUNET_CRYPTO_EddsaPublicKey): cstring {.cdecl,
    importc: "GNUNET_p2s", dynlib: libname.}

proc GNUNET_p2s2*(p: ptr GNUNET_CRYPTO_EddsaPublicKey): cstring {.cdecl,
    importc: "GNUNET_p2s2", dynlib: libname.}

proc GNUNET_e2s*(p: ptr GNUNET_CRYPTO_EcdhePublicKey): cstring {.cdecl,
    importc: "GNUNET_e2s", dynlib: libname.}

proc GNUNET_e2s2*(p: ptr GNUNET_CRYPTO_EcdhePublicKey): cstring {.cdecl,
    importc: "GNUNET_e2s2", dynlib: libname.}

proc GNUNET_i2s*(pid: ptr GNUNET_PeerIdentity): cstring {.cdecl,
    importc: "GNUNET_i2s", dynlib: libname.}

proc GNUNET_i2s2*(pid: ptr GNUNET_PeerIdentity): cstring {.cdecl,
    importc: "GNUNET_i2s2", dynlib: libname.}

proc GNUNET_i2s_full*(pid: ptr GNUNET_PeerIdentity): cstring {.cdecl,
    importc: "GNUNET_i2s_full", dynlib: libname.}

proc GNUNET_error_type_to_string*(kind: GNUNET_ErrorType): cstring {.cdecl,
    importc: "GNUNET_error_type_to_string", dynlib: libname.}

proc GNUNET_htonll*(n: uint64): uint64 {.cdecl, importc: "GNUNET_htonll",
                                     dynlib: libname.}

proc GNUNET_ntohll*(n: uint64): uint64 {.cdecl, importc: "GNUNET_ntohll",
                                     dynlib: libname.}

proc GNUNET_hton_double*(d: cdouble): cdouble {.cdecl, importc: "GNUNET_hton_double",
    dynlib: libname.}

proc GNUNET_ntoh_double*(d: cdouble): cdouble {.cdecl, importc: "GNUNET_ntoh_double",
    dynlib: libname.}

proc GNUNET_snprintf*(buf: cstring; size: csize; format: cstring): cint {.varargs, cdecl,
    importc: "GNUNET_snprintf", dynlib: libname.}

proc GNUNET_asprintf*(buf: cstringArray; format: cstring): cint {.varargs, cdecl,
    importc: "GNUNET_asprintf", dynlib: libname.}

proc GNUNET_copy_message*(msg: ptr GNUNET_MessageHeader): ptr GNUNET_MessageHeader {.
    cdecl, importc: "GNUNET_copy_message", dynlib: libname.}

type
  GNUNET_SCHEDULER_Priority* {.size: sizeof(cint).} = enum
    GNUNET_SCHEDULER_PRIORITY_KEEP = 0, GNUNET_SCHEDULER_PRIORITY_IDLE = 1,
    GNUNET_SCHEDULER_PRIORITY_BACKGROUND = 2,
    GNUNET_SCHEDULER_PRIORITY_DEFAULT = 3, GNUNET_SCHEDULER_PRIORITY_HIGH = 4,
    GNUNET_SCHEDULER_PRIORITY_UI = 5, GNUNET_SCHEDULER_PRIORITY_URGENT = 6,
    GNUNET_SCHEDULER_PRIORITY_SHUTDOWN = 7, GNUNET_SCHEDULER_PRIORITY_COUNT = 8


