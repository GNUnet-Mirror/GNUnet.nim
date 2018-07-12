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
  GNUNET_HashCode* {.bycopy.} = object
    bits*: array[512 div 8 div sizeof((uint32)), uint32]


type
  GNUNET_PeerIdentity* {.bycopy.} = object
    public_key*: GNUNET_CRYPTO_EddsaPublicKey


type
  GNUNET_DISK_FileHandle* {.bycopy.} = object
    fd*: cint


type
  GNUNET_NETWORK_Handle* {.bycopy.} = object

