import gnunet_common, gnunet_crypto_lib

proc peerId*(peer: GNUNET_PeerIdentity): string =
  let peerId = GNUNET_i2s(unsafeAddr peer)
  let peerIdLen = peerId.len()
  result = newString(peerIdLen)
  copyMem(addr result[0], peerId, peerIdLen)

proc fullPeerId*(peer: GNUNET_PeerIdentity): string =
  let peerId = GNUNET_i2s_full(unsafeAddr peer)
  let peerIdLen = peerId.len()
  result = newString(peerIdLen)
  copyMem(addr result[0], peerId, peerIdLen)
