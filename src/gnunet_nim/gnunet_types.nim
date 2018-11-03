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
