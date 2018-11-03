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
  GNUNET_TIME_Absolute* {.bycopy.} = object
    abs_value_us*: uint64



type
  GNUNET_TIME_Relative* {.bycopy.} = object
    rel_value_us*: uint64



proc GNUNET_TIME_absolute_get_forever*(): GNUNET_TIME_Absolute {.cdecl,
    importc: "GNUNET_TIME_absolute_get_forever_", dynlib: libname.}

proc GNUNET_TIME_absolute_get*(): GNUNET_TIME_Absolute {.cdecl,
    importc: "GNUNET_TIME_absolute_get", dynlib: libname.}

