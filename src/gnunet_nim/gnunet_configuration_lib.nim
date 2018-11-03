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

import
  gnunet_time_lib


type
  GNUNET_CONFIGURATION_Handle* {.bycopy.} = object
  


proc GNUNET_CONFIGURATION_create*(): ptr GNUNET_CONFIGURATION_Handle {.cdecl,
    importc: "GNUNET_CONFIGURATION_create", dynlib: libname.}

proc GNUNET_CONFIGURATION_destroy*(cfg: ptr GNUNET_CONFIGURATION_Handle) {.cdecl,
    importc: "GNUNET_CONFIGURATION_destroy", dynlib: libname.}

proc GNUNET_CONFIGURATION_load*(cfg: ptr GNUNET_CONFIGURATION_Handle;
                               filename: cstring): cint {.cdecl,
    importc: "GNUNET_CONFIGURATION_load", dynlib: libname.}

