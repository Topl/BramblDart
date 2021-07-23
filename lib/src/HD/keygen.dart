/// Create a new seed from entropy and password
///
/// The output size of pbkdf2 is associated with the size of the slice, allowing
/// to generate a seed of the size required for various specific cryptographic object

Uint8List generateSeed(Uint8List entropy, Uint8List password) {
  const ITER = 4096;
  final KeyDerivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), 64);
  final params = Pbkdf2Parameters(entropy, ITER, 32);
  keyDerivator.init(params);
  return keyDerivator.process(password);
}