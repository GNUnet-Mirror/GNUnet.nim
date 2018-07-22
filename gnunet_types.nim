const
  GNUNET_OK* = 1
  GNUNET_SYSERR* = -1
  GNUNET_YES* = 1
  GNUNET_NO* = 0

type
  GNUNET_MessageHeader* = object
    size*: uint16
    msg_type*: uint16


type
  GNUNET_CRYPTO_EddsaPublicKey* {.bycopy.} = object
    q_y*: array[256 div 8, cuchar]


type
  GNUNET_CRYPTO_EcdsaPublicKey* {.bycopy.} = object
    q_y*: array[256 div 8, cuchar]


type
  GNUNET_DISK_FileHandle* {.bycopy.} = object
    fd*: cint


type
  GNUNET_NETWORK_Handle* {.bycopy.} = object


type
  GNUNET_SCHEDULER_Priority* {.size: sizeof(cint).} = enum
    GNUNET_SCHEDULER_PRIORITY_KEEP = 0, GNUNET_SCHEDULER_PRIORITY_IDLE = 1,
    GNUNET_SCHEDULER_PRIORITY_BACKGROUND = 2,
    GNUNET_SCHEDULER_PRIORITY_DEFAULT = 3, GNUNET_SCHEDULER_PRIORITY_HIGH = 4,
    GNUNET_SCHEDULER_PRIORITY_UI = 5, GNUNET_SCHEDULER_PRIORITY_URGENT = 6,
    GNUNET_SCHEDULER_PRIORITY_SHUTDOWN = 7, GNUNET_SCHEDULER_PRIORITY_COUNT = 8


