import 'dart:typed_data';

import 'package:pointycastle/api.dart';

import '../../../utils/extensions.dart';

/// super class for all Password Based Encryption (PBE) parameter generator classes.
/// Port from Bouncy Castle Java
abstract class PBEParametersGenerator {
  late Uint8List password;
  late Uint8List salt;
  late int iterationCount;

  /// initialise the PBE generator.
  ///
  /// [password] the password converted into bytes (see below).
  /// [salt] the salt to be mixed with the password.
  /// [iterationCount] the number of iterations the "mixing" function
  /// is to be applied for.
  void init(
    Uint8List password,
    Uint8List salt,
    int iterationCount,
  ) {
    this.password = password;
    this.salt = salt;
    this.iterationCount = iterationCount;
  }

  /// generate derived parameters for a key of length keySize.
  ///
  /// [keySize] the length, in bits, of the key required.
  CipherParameters generateDerivedParameters(int keySize);

  /// generate derived parameters for a key of length keySize, and
  /// an initialisation vector (IV) of length ivSize.
  ///
  /// [keySize] the length, in bits, of the key required.
  /// [ivSize] the length, in bits, of the iv required.
  CipherParameters generateDerivedParametersWithIV(int keySize, int ivSize);

  /// generate derived parameters for a key of length keySize, specifically
  /// for use with a MAC.
  ///
  /// [keySize] the length, in bits, of the key required.
  CipherParameters generateDerivedMacParameters(int keySize);

  /// converts a password to a byte array according to the scheme in
  /// PKCS5 (ascii, no padding)
  ///
  /// [password] a character array representing the password.
  static Uint8List pkcs5PasswordToBytes(String? password) {
    if (password != null && password.isNotEmpty) {
      final pw = password.codeUnits;
      final bytes = Uint8List(pw.length);

      for (var i = 0; i != bytes.length; i++) {
        bytes[i] = pw[i] & 0xff;
      }

      return bytes;
    } else {
      return Uint8List(0);
    }
  }

  /// converts a password to a byte array according to the scheme in
  /// PKCS5 (UTF-8, no padding)
  ///
  /// [password] a character array representing the password.
  static Uint8List pkcs5PasswordToUTF8Bytes(String password) {
    if (password.isNotEmpty) {
      return password.toUtf8Uint8List();
    } else {
      return Uint8List(0);
    }
  }

  /// converts a password to a byte array according to the scheme in
  /// PKCS12 (unicode, big endian, 2 zero pad bytes at the end).
  ///
  /// [password] is a character array representing the password.
  static Uint8List pkcs12PasswordToBytes(String? password) {
    if (password != null && password.isNotEmpty) {
      final pw = password.codeUnits;
      final bytes = Uint8List((pw.length + 1) * 2);

      for (var i = 0; i != pw.length; i++) {
        bytes[i * 2] = (pw[i] >> 8) & 0xff;
        bytes[i * 2 + 1] = pw[i] & 0xff;
      }

      return bytes;
    } else {
      return Uint8List(0);
    }
  }
}
