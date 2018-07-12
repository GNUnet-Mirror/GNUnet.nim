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

import
  gnunet_types, gnunet_mq_lib, gnunet_configuration_lib


const
  GNUNET_CADET_VERSION* = 0x00000005


type
  GNUNET_CADET_Handle* {.bycopy.} = object
  


type
  GNUNET_CADET_Channel* {.bycopy.} = object
  


type
  GNUNET_CADET_Port* {.bycopy.} = object
  


type
  GNUNET_CADET_ChannelOption* {.size: sizeof(cint).} = enum
    GNUNET_CADET_OPTION_DEFAULT = 0x00000000,
    GNUNET_CADET_OPTION_NOBUFFER = 0x00000001,
    GNUNET_CADET_OPTION_RELIABLE = 0x00000002,
    GNUNET_CADET_OPTION_OUT_OF_ORDER = 0x00000004,
    GNUNET_CADET_OPTION_PEER = 0x00000008



type
  GNUNET_CADET_ConnectEventHandler* = proc (cls: pointer;
      channel: ptr GNUNET_CADET_Channel; source: ptr GNUNET_PeerIdentity): pointer {.
      cdecl.}


type
  GNUNET_CADET_DisconnectEventHandler* = proc (cls: pointer;
      channel: ptr GNUNET_CADET_Channel) {.cdecl.}


type
  GNUNET_CADET_WindowSizeEventHandler* = proc (cls: pointer;
      channel: ptr GNUNET_CADET_Channel; window_size: cint) {.cdecl.}


proc GNUNET_CADET_connect*(cfg: ptr GNUNET_CONFIGURATION_Handle): ptr GNUNET_CADET_Handle {.
    cdecl, importc: "GNUNET_CADET_connect", dynlib: libname.}

proc GNUNET_CADET_disconnect*(handle: ptr GNUNET_CADET_Handle) {.cdecl,
    importc: "GNUNET_CADET_disconnect", dynlib: libname.}

proc GNUNET_CADET_open_port*(h: ptr GNUNET_CADET_Handle; port: ptr GNUNET_HashCode;
                            connects: GNUNET_CADET_ConnectEventHandler;
                            connects_cls: pointer; window_changes: GNUNET_CADET_WindowSizeEventHandler;
                            disconnects: GNUNET_CADET_DisconnectEventHandler;
                            handlers: ptr GNUNET_MQ_MessageHandler): ptr GNUNET_CADET_Port {.
    cdecl, importc: "GNUNET_CADET_open_port", dynlib: libname.}

proc GNUNET_CADET_close_port*(p: ptr GNUNET_CADET_Port) {.cdecl,
    importc: "GNUNET_CADET_close_port", dynlib: libname.}

proc GNUNET_CADET_channel_create*(h: ptr GNUNET_CADET_Handle; channel_cls: pointer;
                                 destination: ptr GNUNET_PeerIdentity;
                                 port: ptr GNUNET_HashCode;
                                 options: GNUNET_CADET_ChannelOption;
    window_changes: GNUNET_CADET_WindowSizeEventHandler; disconnects: GNUNET_CADET_DisconnectEventHandler;
                                 handlers: ptr GNUNET_MQ_MessageHandler): ptr GNUNET_CADET_Channel {.
    cdecl, importc: "GNUNET_CADET_channel_create", dynlib: libname.}

proc GNUNET_CADET_channel_destroy*(channel: ptr GNUNET_CADET_Channel) {.cdecl,
    importc: "GNUNET_CADET_channel_destroy", dynlib: libname.}

proc GNUNET_CADET_get_mq*(channel: ptr GNUNET_CADET_Channel): ptr GNUNET_MQ_Handle {.
    cdecl, importc: "GNUNET_CADET_get_mq", dynlib: libname.}

proc GNUNET_CADET_receive_done*(channel: ptr GNUNET_CADET_Channel) {.cdecl,
    importc: "GNUNET_CADET_receive_done", dynlib: libname.}

proc GC_u2h*(port: uint32): ptr GNUNET_HashCode {.cdecl, importc: "GC_u2h",
    dynlib: libname.}

type
  GNUNET_CADET_ChannelInfo* {.bycopy.} = object {.union.}
    yes_no*: cint
    peer*: GNUNET_PeerIdentity



type
  GNUNET_CADET_PeersCB* = proc (cls: pointer; peer: ptr GNUNET_PeerIdentity;
                             tunnel: cint; n_paths: cuint; best_path: cuint) {.cdecl.}


type
  GNUNET_CADET_PeerCB* = proc (cls: pointer; peer: ptr GNUNET_PeerIdentity;
                            tunnel: cint; neighbor: cint; n_paths: cuint;
                            paths: ptr GNUNET_PeerIdentity; offset: cint;
                            finished_with_paths: cint) {.cdecl.}


proc GNUNET_CADET_get_peers*(h: ptr GNUNET_CADET_Handle;
                            callback: GNUNET_CADET_PeersCB; callback_cls: pointer): cint {.
    cdecl, importc: "GNUNET_CADET_get_peers", dynlib: libname.}

proc GNUNET_CADET_get_peers_cancel*(h: ptr GNUNET_CADET_Handle): pointer {.cdecl,
    importc: "GNUNET_CADET_get_peers_cancel", dynlib: libname.}

proc GNUNET_CADET_get_peer*(h: ptr GNUNET_CADET_Handle; id: ptr GNUNET_PeerIdentity;
                           callback: GNUNET_CADET_PeerCB; callback_cls: pointer): cint {.
    cdecl, importc: "GNUNET_CADET_get_peer", dynlib: libname.}

