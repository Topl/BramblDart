import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:cryptography/cryptography.dart';
// import 'package:pointycastle/digests/sha512.dart';
// import 'package:pointycastle/key_derivators/api.dart';
// import 'package:pointycastle/key_derivators/pbkdf2.dart';
// import 'package:pointycastle/macs/hmac.dart';

abstract class EntropyToSeed {
  const EntropyToSeed();

  Future<Uint8List> toSeed(Entropy entropy, String? password,
      {required int seedLength}) async {
    final kdf = Pbkdf2Sha512();
    // Defaulting to String value of "None", KDF will not accept blank values.
    return await kdf.generateKey(
        password ?? "None", entropy.value, seedLength, 4096);
  }
}

class Pbkdf2Sha512 extends EntropyToSeed {
  const Pbkdf2Sha512();

  /// Generates a public key from the given message and salt.
  ///
  /// Runs HMAC-SHA512 a given number of iterations and creates a key of given size.
  ///
  /// Uses the [password] to create the public key, and then apllies the [salt] to the key.
  /// Applies the [keySizeBytes] to the key and runs [iterations] times.
  ///
  /// Will return a [Uint8List] of the generated key.
  Future<Uint8List> generateKey(
      String password, Uint8List salt, int keySizeBytes, int iterations) async {
    // Uint8List password, Uint8List salt, int keySizeBytes, int iterations) async {
    // final generator = PBKDF2KeyDerivator(HMac.sha512());
    // final params = Pbkdf2Parameters(salt, iterations, keySizeBytes.toBits);
    // generator.init(params);
    // return generator.process(password);

    final kdf = Pbkdf2(
      macAlgorithm: Hmac.sha512(),
      iterations: iterations,
      bits: keySizeBytes.toBits,
    );

    final key =
        await kdf.deriveKeyFromPassword(password: password, nonce: salt);
    return (await key.extractBytes()).toUint8List();
  }
}
