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


type
  GNUNET_HashCode* {.bycopy.} = object
    bits*: array[512 div 8 div sizeof((uint32)), uint32]



type
  GNUNET_ShortHashCode* {.bycopy.} = object
    bits*: array[256 div 8 div sizeof((uint32)), uint32]



import
  gnunet_types, gnunet_configuration_lib


const
  GNUNET_CRYPTO_ECC_SIGNATURE_DATA_ENCODING_LENGTH* = 126


type
  GNUNET_CRYPTO_Quality* {.size: sizeof(cint).} = enum
    GNUNET_CRYPTO_QUALITY_WEAK, GNUNET_CRYPTO_QUALITY_STRONG,
    GNUNET_CRYPTO_QUALITY_NONCE



const
  GNUNET_CRYPTO_AES_KEY_LENGTH* = (256 div 8)


const
  GNUNET_CRYPTO_HASH_LENGTH* = (512 div 8)


const
  GNUNET_CRYPTO_PKEY_ASCII_LENGTH* = 52


type
  GNUNET_CRYPTO_HashAsciiEncoded* {.bycopy.} = object
    encoding*: array[104, cuchar]



type
  GNUNET_CRYPTO_EddsaSignature* {.bycopy.} = object
    r*: array[256 div 8, cuchar]
    s*: array[256 div 8, cuchar]



type
  GNUNET_CRYPTO_EcdsaSignature* {.bycopy.} = object
    r*: array[256 div 8, cuchar]
    s*: array[256 div 8, cuchar]



type
  GNUNET_CRYPTO_EddsaPublicKey* {.bycopy.} = object
    q_y*: array[256 div 8, cuchar]



type
  GNUNET_CRYPTO_EcdsaPublicKey* {.bycopy.} = object
    q_y*: array[256 div 8, cuchar]



type
  GNUNET_PeerIdentity* {.bycopy.} = object
    public_key*: GNUNET_CRYPTO_EddsaPublicKey



type
  GNUNET_CRYPTO_EcdhePublicKey* {.bycopy.} = object
    q_y*: array[256 div 8, cuchar]



type
  GNUNET_CRYPTO_EcdhePrivateKey* {.bycopy.} = object
    d*: array[256 div 8, cuchar]



type
  GNUNET_CRYPTO_EcdsaPrivateKey* {.bycopy.} = object
    d*: array[256 div 8, cuchar]



type
  GNUNET_CRYPTO_EddsaPrivateKey* {.bycopy.} = object
    d*: array[256 div 8, cuchar]



type
  GNUNET_CRYPTO_SymmetricSessionKey* {.bycopy.} = object
    aes_key*: array[GNUNET_CRYPTO_AES_KEY_LENGTH, cuchar]
    twofish_key*: array[GNUNET_CRYPTO_AES_KEY_LENGTH, cuchar]



type
  GNUNET_CRYPTO_SymmetricInitializationVector* {.bycopy.} = object
    aes_iv*: array[GNUNET_CRYPTO_AES_KEY_LENGTH div 2, cuchar]
    twofish_iv*: array[GNUNET_CRYPTO_AES_KEY_LENGTH div 2, cuchar]



type
  GNUNET_CRYPTO_AuthKey* {.bycopy.} = object
    key*: array[GNUNET_CRYPTO_HASH_LENGTH, cuchar]



const
  GNUNET_CRYPTO_PAILLIER_BITS* = 2048


type
  GNUNET_CRYPTO_PaillierPublicKey* {.bycopy.} = object
    n*: array[GNUNET_CRYPTO_PAILLIER_BITS div 8, cuchar]



type
  GNUNET_CRYPTO_PaillierPrivateKey* {.bycopy.} = object
    lambda*: array[GNUNET_CRYPTO_PAILLIER_BITS div 8, cuchar]
    mu*: array[GNUNET_CRYPTO_PAILLIER_BITS div 8, cuchar]



proc GNUNET_CRYPTO_seed_weak_random*(seed: int32) {.cdecl,
    importc: "GNUNET_CRYPTO_seed_weak_random", dynlib: libname.}

proc GNUNET_CRYPTO_crc8_n*(buf: pointer; len: csize): uint8 {.cdecl,
    importc: "GNUNET_CRYPTO_crc8_n", dynlib: libname.}

proc GNUNET_CRYPTO_crc16_step*(sum: uint32; buf: pointer; len: csize): uint32 {.cdecl,
    importc: "GNUNET_CRYPTO_crc16_step", dynlib: libname.}

proc GNUNET_CRYPTO_crc16_finish*(sum: uint32): uint16 {.cdecl,
    importc: "GNUNET_CRYPTO_crc16_finish", dynlib: libname.}

proc GNUNET_CRYPTO_crc16_n*(buf: pointer; len: csize): uint16 {.cdecl,
    importc: "GNUNET_CRYPTO_crc16_n", dynlib: libname.}

proc GNUNET_CRYPTO_crc32_n*(buf: pointer; len: csize): int32 {.cdecl,
    importc: "GNUNET_CRYPTO_crc32_n", dynlib: libname.}

proc GNUNET_CRYPTO_random_block*(mode: GNUNET_CRYPTO_Quality; buffer: pointer;
                                length: csize) {.cdecl,
    importc: "GNUNET_CRYPTO_random_block", dynlib: libname.}

proc GNUNET_CRYPTO_random_u32*(mode: GNUNET_CRYPTO_Quality; i: uint32): uint32 {.
    cdecl, importc: "GNUNET_CRYPTO_random_u32", dynlib: libname.}

proc GNUNET_CRYPTO_random_u64*(mode: GNUNET_CRYPTO_Quality; max: uint64): uint64 {.
    cdecl, importc: "GNUNET_CRYPTO_random_u64", dynlib: libname.}

proc GNUNET_CRYPTO_random_permute*(mode: GNUNET_CRYPTO_Quality; n: cuint): ptr cuint {.
    cdecl, importc: "GNUNET_CRYPTO_random_permute", dynlib: libname.}

proc GNUNET_CRYPTO_symmetric_create_session_key*(
    key: ptr GNUNET_CRYPTO_SymmetricSessionKey) {.cdecl,
    importc: "GNUNET_CRYPTO_symmetric_create_session_key", dynlib: libname.}

proc GNUNET_CRYPTO_symmetric_encrypt*(`block`: pointer; size: csize; sessionkey: ptr GNUNET_CRYPTO_SymmetricSessionKey;
    iv: ptr GNUNET_CRYPTO_SymmetricInitializationVector; result: pointer): int {.
    cdecl, importc: "GNUNET_CRYPTO_symmetric_encrypt", dynlib: libname.}

proc GNUNET_CRYPTO_symmetric_decrypt*(`block`: pointer; size: csize; sessionkey: ptr GNUNET_CRYPTO_SymmetricSessionKey;
    iv: ptr GNUNET_CRYPTO_SymmetricInitializationVector; result: pointer): int {.
    cdecl, importc: "GNUNET_CRYPTO_symmetric_decrypt", dynlib: libname.}

proc GNUNET_CRYPTO_hash_to_enc*(`block`: ptr GNUNET_HashCode;
                               result: ptr GNUNET_CRYPTO_HashAsciiEncoded) {.cdecl,
    importc: "GNUNET_CRYPTO_hash_to_enc", dynlib: libname.}

proc GNUNET_CRYPTO_hash_from_string2*(enc: cstring; enclen: csize;
                                     result: ptr GNUNET_HashCode): cint {.cdecl,
    importc: "GNUNET_CRYPTO_hash_from_string2", dynlib: libname.}

template GNUNET_CRYPTO_hash_from_string*(enc, result: untyped): untyped =
  GNUNET_CRYPTO_hash_from_string2(enc, strlen(enc), result)


proc GNUNET_CRYPTO_hash_distance_u32*(a: ptr GNUNET_HashCode; b: ptr GNUNET_HashCode): uint32 {.
    cdecl, importc: "GNUNET_CRYPTO_hash_distance_u32", dynlib: libname.}

proc GNUNET_CRYPTO_hash*(`block`: pointer; size: csize; ret: ptr GNUNET_HashCode) {.
    cdecl, importc: "GNUNET_CRYPTO_hash", dynlib: libname.}

type
  GNUNET_HashContext* {.bycopy.} = object
  


proc GNUNET_CRYPTO_hash_context_start*(): ptr GNUNET_HashContext {.cdecl,
    importc: "GNUNET_CRYPTO_hash_context_start", dynlib: libname.}

proc GNUNET_CRYPTO_hash_context_read*(hc: ptr GNUNET_HashContext; buf: pointer;
                                     size: csize) {.cdecl,
    importc: "GNUNET_CRYPTO_hash_context_read", dynlib: libname.}

proc GNUNET_CRYPTO_hash_context_finish*(hc: ptr GNUNET_HashContext;
                                       r_hash: ptr GNUNET_HashCode) {.cdecl,
    importc: "GNUNET_CRYPTO_hash_context_finish", dynlib: libname.}

proc GNUNET_CRYPTO_hash_context_abort*(hc: ptr GNUNET_HashContext) {.cdecl,
    importc: "GNUNET_CRYPTO_hash_context_abort", dynlib: libname.}

proc GNUNET_CRYPTO_hmac*(key: ptr GNUNET_CRYPTO_AuthKey; plaintext: pointer;
                        plaintext_len: csize; hmac: ptr GNUNET_HashCode) {.cdecl,
    importc: "GNUNET_CRYPTO_hmac", dynlib: libname.}

type
  GNUNET_CRYPTO_HashCompletedCallback* = proc (cls: pointer; res: ptr GNUNET_HashCode) {.
      cdecl.}


type
  GNUNET_CRYPTO_FileHashContext* {.bycopy.} = object
  


proc GNUNET_CRYPTO_hash_file*(priority: GNUNET_SCHEDULER_Priority;
                             filename: cstring; blocksize: csize;
                             callback: GNUNET_CRYPTO_HashCompletedCallback;
                             callback_cls: pointer): ptr GNUNET_CRYPTO_FileHashContext {.
    cdecl, importc: "GNUNET_CRYPTO_hash_file", dynlib: libname.}

proc GNUNET_CRYPTO_hash_file_cancel*(fhc: ptr GNUNET_CRYPTO_FileHashContext) {.
    cdecl, importc: "GNUNET_CRYPTO_hash_file_cancel", dynlib: libname.}

proc GNUNET_CRYPTO_hash_create_random*(mode: GNUNET_CRYPTO_Quality;
                                      result: ptr GNUNET_HashCode) {.cdecl,
    importc: "GNUNET_CRYPTO_hash_create_random", dynlib: libname.}

proc GNUNET_CRYPTO_hash_difference*(a: ptr GNUNET_HashCode; b: ptr GNUNET_HashCode;
                                   result: ptr GNUNET_HashCode) {.cdecl,
    importc: "GNUNET_CRYPTO_hash_difference", dynlib: libname.}

proc GNUNET_CRYPTO_hash_sum*(a: ptr GNUNET_HashCode; delta: ptr GNUNET_HashCode;
                            result: ptr GNUNET_HashCode) {.cdecl,
    importc: "GNUNET_CRYPTO_hash_sum", dynlib: libname.}

proc GNUNET_CRYPTO_hash_xor*(a: ptr GNUNET_HashCode; b: ptr GNUNET_HashCode;
                            result: ptr GNUNET_HashCode) {.cdecl,
    importc: "GNUNET_CRYPTO_hash_xor", dynlib: libname.}

proc GNUNET_CRYPTO_hash_to_aes_key*(hc: ptr GNUNET_HashCode;
                                   skey: ptr GNUNET_CRYPTO_SymmetricSessionKey; iv: ptr GNUNET_CRYPTO_SymmetricInitializationVector) {.
    cdecl, importc: "GNUNET_CRYPTO_hash_to_aes_key", dynlib: libname.}

proc GNUNET_CRYPTO_hash_get_bit*(code: ptr GNUNET_HashCode; bit: cuint): cint {.cdecl,
    importc: "GNUNET_CRYPTO_hash_get_bit", dynlib: libname.}

proc GNUNET_CRYPTO_hash_matching_bits*(first: ptr GNUNET_HashCode;
                                      second: ptr GNUNET_HashCode): cuint {.cdecl,
    importc: "GNUNET_CRYPTO_hash_matching_bits", dynlib: libname.}

proc GNUNET_CRYPTO_hash_cmp*(h1: ptr GNUNET_HashCode; h2: ptr GNUNET_HashCode): cint {.
    cdecl, importc: "GNUNET_CRYPTO_hash_cmp", dynlib: libname.}

proc GNUNET_CRYPTO_hash_xorcmp*(h1: ptr GNUNET_HashCode; h2: ptr GNUNET_HashCode;
                               target: ptr GNUNET_HashCode): cint {.cdecl,
    importc: "GNUNET_CRYPTO_hash_xorcmp", dynlib: libname.}

proc GNUNET_CRYPTO_ecdsa_key_get_public*(priv: ptr GNUNET_CRYPTO_EcdsaPrivateKey;
                                        pub: ptr GNUNET_CRYPTO_EcdsaPublicKey) {.
    cdecl, importc: "GNUNET_CRYPTO_ecdsa_key_get_public", dynlib: libname.}

proc GNUNET_CRYPTO_eddsa_key_get_public*(priv: ptr GNUNET_CRYPTO_EddsaPrivateKey;
                                        pub: ptr GNUNET_CRYPTO_EddsaPublicKey) {.
    cdecl, importc: "GNUNET_CRYPTO_eddsa_key_get_public", dynlib: libname.}

proc GNUNET_CRYPTO_ecdhe_key_get_public*(priv: ptr GNUNET_CRYPTO_EcdhePrivateKey;
                                        pub: ptr GNUNET_CRYPTO_EcdhePublicKey) {.
    cdecl, importc: "GNUNET_CRYPTO_ecdhe_key_get_public", dynlib: libname.}

proc GNUNET_CRYPTO_ecdsa_public_key_to_string*(
    pub: ptr GNUNET_CRYPTO_EcdsaPublicKey): cstring {.cdecl,
    importc: "GNUNET_CRYPTO_ecdsa_public_key_to_string", dynlib: libname.}

proc GNUNET_CRYPTO_eddsa_private_key_to_string*(
    priv: ptr GNUNET_CRYPTO_EddsaPrivateKey): cstring {.cdecl,
    importc: "GNUNET_CRYPTO_eddsa_private_key_to_string", dynlib: libname.}

proc GNUNET_CRYPTO_eddsa_public_key_to_string*(
    pub: ptr GNUNET_CRYPTO_EddsaPublicKey): cstring {.cdecl,
    importc: "GNUNET_CRYPTO_eddsa_public_key_to_string", dynlib: libname.}

proc GNUNET_CRYPTO_ecdsa_public_key_from_string*(enc: cstring; enclen: csize;
    pub: ptr GNUNET_CRYPTO_EcdsaPublicKey): cint {.cdecl,
    importc: "GNUNET_CRYPTO_ecdsa_public_key_from_string", dynlib: libname.}

proc GNUNET_CRYPTO_eddsa_private_key_from_string*(enc: cstring; enclen: csize;
    pub: ptr GNUNET_CRYPTO_EddsaPrivateKey): cint {.cdecl,
    importc: "GNUNET_CRYPTO_eddsa_private_key_from_string", dynlib: libname.}

proc GNUNET_CRYPTO_eddsa_public_key_from_string*(enc: cstring; enclen: csize;
    pub: ptr GNUNET_CRYPTO_EddsaPublicKey): cint {.cdecl,
    importc: "GNUNET_CRYPTO_eddsa_public_key_from_string", dynlib: libname.}

proc GNUNET_CRYPTO_ecdsa_key_create_from_file*(filename: cstring): ptr GNUNET_CRYPTO_EcdsaPrivateKey {.
    cdecl, importc: "GNUNET_CRYPTO_ecdsa_key_create_from_file", dynlib: libname.}

proc GNUNET_CRYPTO_eddsa_key_create_from_file*(filename: cstring): ptr GNUNET_CRYPTO_EddsaPrivateKey {.
    cdecl, importc: "GNUNET_CRYPTO_eddsa_key_create_from_file", dynlib: libname.}

proc GNUNET_CRYPTO_eddsa_key_create_from_configuration*(
    cfg: ptr GNUNET_CONFIGURATION_Handle): ptr GNUNET_CRYPTO_EddsaPrivateKey {.cdecl,
    importc: "GNUNET_CRYPTO_eddsa_key_create_from_configuration", dynlib: libname.}

proc GNUNET_CRYPTO_ecdsa_key_create*(): ptr GNUNET_CRYPTO_EcdsaPrivateKey {.cdecl,
    importc: "GNUNET_CRYPTO_ecdsa_key_create", dynlib: libname.}

proc GNUNET_CRYPTO_eddsa_key_create*(): ptr GNUNET_CRYPTO_EddsaPrivateKey {.cdecl,
    importc: "GNUNET_CRYPTO_eddsa_key_create", dynlib: libname.}

proc GNUNET_CRYPTO_ecdhe_key_create2*(pk: ptr GNUNET_CRYPTO_EcdhePrivateKey): cint {.
    cdecl, importc: "GNUNET_CRYPTO_ecdhe_key_create2", dynlib: libname.}

proc GNUNET_CRYPTO_ecdhe_key_create*(): ptr GNUNET_CRYPTO_EcdhePrivateKey {.cdecl,
    importc: "GNUNET_CRYPTO_ecdhe_key_create", dynlib: libname.}

proc GNUNET_CRYPTO_eddsa_key_clear*(pk: ptr GNUNET_CRYPTO_EddsaPrivateKey) {.cdecl,
    importc: "GNUNET_CRYPTO_eddsa_key_clear", dynlib: libname.}

proc GNUNET_CRYPTO_ecdsa_key_clear*(pk: ptr GNUNET_CRYPTO_EcdsaPrivateKey) {.cdecl,
    importc: "GNUNET_CRYPTO_ecdsa_key_clear", dynlib: libname.}

proc GNUNET_CRYPTO_ecdhe_key_clear*(pk: ptr GNUNET_CRYPTO_EcdhePrivateKey) {.cdecl,
    importc: "GNUNET_CRYPTO_ecdhe_key_clear", dynlib: libname.}

proc GNUNET_CRYPTO_ecdsa_key_get_anonymous*(): ptr GNUNET_CRYPTO_EcdsaPrivateKey {.
    cdecl, importc: "GNUNET_CRYPTO_ecdsa_key_get_anonymous", dynlib: libname.}

proc GNUNET_CRYPTO_eddsa_setup_hostkey*(cfg_name: cstring) {.cdecl,
    importc: "GNUNET_CRYPTO_eddsa_setup_hostkey", dynlib: libname.}

proc GNUNET_CRYPTO_get_peer_identity*(cfg: ptr GNUNET_CONFIGURATION_Handle;
                                     dst: ptr GNUNET_PeerIdentity): cint {.cdecl,
    importc: "GNUNET_CRYPTO_get_peer_identity", dynlib: libname.}

proc GNUNET_CRYPTO_cmp_peer_identity*(first: ptr GNUNET_PeerIdentity;
                                     second: ptr GNUNET_PeerIdentity): cint {.cdecl,
    importc: "GNUNET_CRYPTO_cmp_peer_identity", dynlib: libname.}

type
  GNUNET_CRYPTO_EccDlogContext* {.bycopy.} = object
  


type
  GNUNET_CRYPTO_EccPoint* {.bycopy.} = object
    q_y*: array[256 div 8, cuchar]



proc GNUNET_CRYPTO_eddsa_ecdh*(priv: ptr GNUNET_CRYPTO_EddsaPrivateKey;
                              pub: ptr GNUNET_CRYPTO_EcdhePublicKey;
                              key_material: ptr GNUNET_HashCode): cint {.cdecl,
    importc: "GNUNET_CRYPTO_eddsa_ecdh", dynlib: libname.}

proc GNUNET_CRYPTO_ecdsa_ecdh*(priv: ptr GNUNET_CRYPTO_EcdsaPrivateKey;
                              pub: ptr GNUNET_CRYPTO_EcdhePublicKey;
                              key_material: ptr GNUNET_HashCode): cint {.cdecl,
    importc: "GNUNET_CRYPTO_ecdsa_ecdh", dynlib: libname.}

proc GNUNET_CRYPTO_ecdh_eddsa*(priv: ptr GNUNET_CRYPTO_EcdhePrivateKey;
                              pub: ptr GNUNET_CRYPTO_EddsaPublicKey;
                              key_material: ptr GNUNET_HashCode): cint {.cdecl,
    importc: "GNUNET_CRYPTO_ecdh_eddsa", dynlib: libname.}

proc GNUNET_CRYPTO_ecdh_ecdsa*(priv: ptr GNUNET_CRYPTO_EcdhePrivateKey;
                              pub: ptr GNUNET_CRYPTO_EcdsaPublicKey;
                              key_material: ptr GNUNET_HashCode): cint {.cdecl,
    importc: "GNUNET_CRYPTO_ecdh_ecdsa", dynlib: libname.}

proc GNUNET_CRYPTO_ecdsa_private_key_derive*(
    priv: ptr GNUNET_CRYPTO_EcdsaPrivateKey; label: cstring; context: cstring): ptr GNUNET_CRYPTO_EcdsaPrivateKey {.
    cdecl, importc: "GNUNET_CRYPTO_ecdsa_private_key_derive", dynlib: libname.}

proc GNUNET_CRYPTO_ecdsa_public_key_derive*(
    pub: ptr GNUNET_CRYPTO_EcdsaPublicKey; label: cstring; context: cstring;
    result: ptr GNUNET_CRYPTO_EcdsaPublicKey) {.cdecl,
    importc: "GNUNET_CRYPTO_ecdsa_public_key_derive", dynlib: libname.}

type
  GNUNET_CRYPTO_RsaPrivateKey* {.bycopy.} = object
  


type
  GNUNET_CRYPTO_RsaPublicKey* {.bycopy.} = object
  


type
  GNUNET_CRYPTO_RsaSignature* {.bycopy.} = object
  


proc GNUNET_CRYPTO_rsa_private_key_create*(len: cuint): ptr GNUNET_CRYPTO_RsaPrivateKey {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_private_key_create", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_private_key_free*(key: ptr GNUNET_CRYPTO_RsaPrivateKey) {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_private_key_free", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_private_key_encode*(key: ptr GNUNET_CRYPTO_RsaPrivateKey;
    buffer: cstringArray): csize {.cdecl, importc: "GNUNET_CRYPTO_rsa_private_key_encode",
                                dynlib: libname.}

proc GNUNET_CRYPTO_rsa_private_key_decode*(buf: cstring; len: csize): ptr GNUNET_CRYPTO_RsaPrivateKey {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_private_key_decode", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_private_key_dup*(key: ptr GNUNET_CRYPTO_RsaPrivateKey): ptr GNUNET_CRYPTO_RsaPrivateKey {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_private_key_dup", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_private_key_get_public*(
    priv: ptr GNUNET_CRYPTO_RsaPrivateKey): ptr GNUNET_CRYPTO_RsaPublicKey {.cdecl,
    importc: "GNUNET_CRYPTO_rsa_private_key_get_public", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_public_key_hash*(key: ptr GNUNET_CRYPTO_RsaPublicKey;
                                       hc: ptr GNUNET_HashCode) {.cdecl,
    importc: "GNUNET_CRYPTO_rsa_public_key_hash", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_public_key_len*(key: ptr GNUNET_CRYPTO_RsaPublicKey): cuint {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_public_key_len", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_public_key_free*(key: ptr GNUNET_CRYPTO_RsaPublicKey) {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_public_key_free", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_public_key_encode*(key: ptr GNUNET_CRYPTO_RsaPublicKey;
    buffer: cstringArray): csize {.cdecl,
                                importc: "GNUNET_CRYPTO_rsa_public_key_encode",
                                dynlib: libname.}

proc GNUNET_CRYPTO_rsa_public_key_decode*(buf: cstring; len: csize): ptr GNUNET_CRYPTO_RsaPublicKey {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_public_key_decode", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_public_key_dup*(key: ptr GNUNET_CRYPTO_RsaPublicKey): ptr GNUNET_CRYPTO_RsaPublicKey {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_public_key_dup", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_signature_cmp*(s1: ptr GNUNET_CRYPTO_RsaSignature;
                                     s2: ptr GNUNET_CRYPTO_RsaSignature): cint {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_signature_cmp", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_private_key_cmp*(p1: ptr GNUNET_CRYPTO_RsaPrivateKey;
                                       p2: ptr GNUNET_CRYPTO_RsaPrivateKey): cint {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_private_key_cmp", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_public_key_cmp*(p1: ptr GNUNET_CRYPTO_RsaPublicKey;
                                      p2: ptr GNUNET_CRYPTO_RsaPublicKey): cint {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_public_key_cmp", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_sign_fdh*(key: ptr GNUNET_CRYPTO_RsaPrivateKey;
                                hash: ptr GNUNET_HashCode): ptr GNUNET_CRYPTO_RsaSignature {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_sign_fdh", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_signature_free*(sig: ptr GNUNET_CRYPTO_RsaSignature) {.cdecl,
    importc: "GNUNET_CRYPTO_rsa_signature_free", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_signature_encode*(sig: ptr GNUNET_CRYPTO_RsaSignature;
                                        buffer: cstringArray): csize {.cdecl,
    importc: "GNUNET_CRYPTO_rsa_signature_encode", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_signature_decode*(buf: cstring; len: csize): ptr GNUNET_CRYPTO_RsaSignature {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_signature_decode", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_signature_dup*(sig: ptr GNUNET_CRYPTO_RsaSignature): ptr GNUNET_CRYPTO_RsaSignature {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_signature_dup", dynlib: libname.}

proc GNUNET_CRYPTO_rsa_verify*(hash: ptr GNUNET_HashCode;
                              sig: ptr GNUNET_CRYPTO_RsaSignature;
                              public_key: ptr GNUNET_CRYPTO_RsaPublicKey): cint {.
    cdecl, importc: "GNUNET_CRYPTO_rsa_verify", dynlib: libname.}

