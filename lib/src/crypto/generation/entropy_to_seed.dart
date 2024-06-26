import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/sha512.dart';

import '../../utils/extensions.dart';
import '../signing/kdf/pkcs5s2_parameters_generator.dart';
import 'mnemonic/entropy.dart';

abstract class EntropyToSeed {
  const EntropyToSeed();

  Uint8List toSeed(Entropy entropy, String? password, {required int seedLength}) {
    const kdf = Pbkdf2Sha512();

    return kdf.generateKey(password ?? "", entropy.value, seedLength, 4096);
  }
}

/// PBKDF-SHA512 defines a function for creating a public key from a password and salt.
///
/// It repeats the HMAC-SHA512 hashing function a given number of iterations and then slices a number of bytes off the
/// result.
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
  Uint8List generateKey(
    String password,
    Uint8List salt,
    int keySizeBytes,
    int iterations,
  ) {
    final generator = PKCS5S2ParametersGenerator(SHA512Digest());
    generator.init(password.toUtf8Uint8List(), salt, iterations);
    final param = generator.generateDerivedParameters(keySizeBytes.toBits) as KeyParameter;
    return param.key;
  }
}
