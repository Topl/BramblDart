import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../../../utils/extensions.dart';
import '../../hash/sha.dart';
import 'ec.dart';

class Ed25519 extends EC {
  final defaultDigest = SHA512();
  final _random = Random.secure();

  /// Updates a SHA512 hash with the domain separation constant [DOM2_PREFIX],
  /// a flag indicating whether the message is prehashed [phflag], and a context value [context].'
  void _dom2(SHA512 d, int phflag, Uint8List ctx) {
    if (ctx.isNotEmpty) {
      d.update(DOM2_PREFIX.toUtf8Uint8List(), 0, DOM2_PREFIX.length);
      d.updateByte(phflag);
      d.updateByte(ctx.length);
      d.update(ctx, 0, ctx.length);
    }
  }

  void generatePrivateKey(Uint8List k) {
    for (var i = 0; i < k.length; i++) {
      k[i] = _random.nextInt(256);
    }
    throw UnimplementedError("Not checked");
  }

  void generatePublicKey(Uint8List sk, int skOff, Uint8List pk, int pkOff,
      {SHA512? digest}) {
    final d = digest ?? defaultDigest;

    final h = Uint8List(d.digestSize);
    d.update(sk, skOff, SECRET_KEY_SIZE);
    d.doFinal(h, 0);
    final s = Uint8List(SCALAR_BYTES);
    pruneScalar(h, 0, s);

    scalarMultBaseEncoded(s, pk, pkOff);
  }

  /// Computes the Ed25519 signature of a message using a digest and a public key.
  ///
  /// The signature is computed as follows:
  ///
  /// 1. Add the domain separator to the hash context.
  /// 2. Update the hash context with the message hash.
  /// 3. Compute a random scalar `r` and the corresponding point `R` by scalar multiplication of the base point with `r`.
  /// 4. Add the domain separator to the hash context.
  /// 5. Update the hash context with the point `R`, the public key, and the message hash.
  /// 6. Compute the scalar `k` and the signature scalar `S` using the `calculateS` function.
  /// 7. Copy the values of `R` and `S` into the signature buffer.
  void implSignWithDigestAndPublicKey(
      SHA512 digest,
      Uint8List h,
      Uint8List s,
      Uint8List pk,
      int pkOffset,
      Uint8List context,
      int phflag,
      Uint8List message,
      int messageOffset,
      int messageLength,
      Uint8List signature,
      int signatureOffset) {
    // Add domain separator to hash context
    _dom2(digest, phflag, context);

    // Update hash context with message hash
    digest.update(h, SCALAR_BYTES, SCALAR_BYTES);
    digest.update(message, messageOffset, messageLength);
    digest.doFinal(h, 0);

    // Compute random scalar r and corresponding point R
    final r = reduceScalar(h);
    final R = Uint8List(POINT_BYTES);
    scalarMultBaseEncoded(r, R, 0);

    // Add domain separator to hash context
    _dom2(digest, phflag, context);

    // Update hash context with point R, public key, and message hash
    digest.update(R, 0, POINT_BYTES);
    digest.update(pk, pkOffset, POINT_BYTES);
    digest.update(message, messageOffset, messageLength);
    digest.doFinal(h, 0);

    // Compute scalar k and signature scalar S
    final k = reduceScalar(h);
    final S = calculateS(r, k, s);

    // Copy R and S values into signature array
    signature.setRange(signatureOffset, signatureOffset + POINT_BYTES, R);
    signature.setRange(signatureOffset + POINT_BYTES,
        signatureOffset + POINT_BYTES + SCALAR_BYTES, S);
  }

  /// Computes the Ed25519 signature of a message using a private key.
  ///
  /// The signature is computed as follows:
  ///
  /// 1. Compute the SHA-512 hash of the private key.
  /// 2. Prune the hash to obtain a 32-byte scalar value.
  /// 3. Compute the public key by scalar multiplication of the base point with the scalar value.
  /// 4. Call the `implSignWithDigestAndPublicKey` function with the computed values and the remaining arguments.
  ///
  /// Throws an [ArgumentError] if the context variable is invalid.
  void implSignWithPrivateKey(
    Uint8List sk,
    int skOffset,
    Uint8List context,
    int phflag,
    Uint8List message,
    int messageOffset,
    int messageLength,
    Uint8List signature,
    int signatureOffset,
  ) {
    if (!checkContextVar(context, phflag)) {
      throw ArgumentError("Invalid context");
    }

    // Compute the SHA-512 hash of the private key.
    final h = Uint8List(defaultDigest.digestSize);
    defaultDigest.update(sk, skOffset, SECRET_KEY_SIZE);
    defaultDigest.doFinal(h, 0);

    // Prune the hash to obtain a 32-byte scalar value.
    final s = Uint8List(SCALAR_BYTES);
    pruneScalar(h, 0, s);

    // Compute the public key by scalar multiplication of the base point with the scalar value.
    final pk = Uint8List(POINT_BYTES);
    scalarMultBaseEncoded(s, pk, 0);

    // Call the `implSignWithDigestAndPublicKey` function with the computed values and the remaining arguments.
    implSignWithDigestAndPublicKey(
      defaultDigest,
      h,
      s,
      pk,
      0,
      context,
      phflag,
      message,
      messageOffset,
      messageLength,
      signature,
      signatureOffset,
    );
  }

  /// Computes the Ed25519 signature of a message using a private key and a public key.
  ///
  /// The signature is computed as follows:
  ///
  /// 1. Compute the SHA-512 hash of the private key.
  /// 2. Prune the hash to obtain a 32-byte scalar value.
  /// 3. Call the `implSignWithDigestAndPublicKey` function with the computed scalar value and the remaining arguments.
  ///
  void implSignWithPrivateKeyAndPublicKey(
    Uint8List sk,
    int skOffset,
    Uint8List pk,
    int pkOffset,
    Uint8List context,
    int phflag,
    Uint8List message,
    int messageOffset,
    int messageLength,
    Uint8List signature,
    int signatureOffset,
  ) {
    // Check if the context variable is valid.
    if (!checkContextVar(context, phflag)) {
      throw ArgumentError("Invalid context");
    }

    // Compute the SHA-512 hash of the private key.
    final h = Uint8List(defaultDigest.digestSize);
    defaultDigest.update(sk, skOffset, SECRET_KEY_SIZE);
    defaultDigest.doFinal(h, 0);

    // Prune the hash to obtain a 32-byte scalar value.
    final s = Uint8List(SCALAR_BYTES);
    pruneScalar(h, 0, s);

    // Call the `implSignWithDigestAndPublicKey` function with the computed values and the remaining arguments.
    implSignWithDigestAndPublicKey(
      defaultDigest,
      h,
      s,
      pk,
      pkOffset,
      context,
      phflag,
      message,
      messageOffset,
      messageLength,
      signature,
      signatureOffset,
    );
  }

  bool _implVerify(
    Uint8List signature,
    int signatureOffset,
    Uint8List pk,
    int pkOffset,
    Uint8List context,
    int phflag,
    Uint8List message,
    int messageOffset,
    int messageLength,
  ) {
    // Check if the context variable is valid.
    if (!checkContextVar(context, phflag)) {
      throw ArgumentError("Invalid context");
    }

    // Extract the R and S components from the signature.
    final R = signature.sublist(signatureOffset, signatureOffset + POINT_BYTES);
    final S = signature.sublist(
        signatureOffset + POINT_BYTES, signatureOffset + SIGNATURE_SIZE);

    // Check if the R and S components are valid.
    if (!checkPointVar(R)) return false;
    if (!checkScalarVar(S)) return false;

    // Decode the public key.
    final pA = PointExt.create();
    if (!decodePointVar(pk, pkOffset, negate: true, r: pA)) return false;

    // Compute the SHA-512 hash of the message and the other parameters.
    final h = Uint8List(defaultDigest.digestSize);
    _dom2(defaultDigest, phflag, context);
    defaultDigest.update(R, 0, POINT_BYTES);
    defaultDigest.update(pk, pkOffset, POINT_BYTES);
    defaultDigest.update(message, messageOffset, messageLength);
    defaultDigest.doFinal(h, 0);

    // Reduce the hash to obtain a scalar value.
    final k = reduceScalar(h);

    // Decode the S component of the signature and the scalar value k.
    final nS = Int32List.fromList(List<int>.filled(SCALAR_INTS, 0));
    decodeScalar(S, 0, nS);

    final nA = Int32List.fromList(List<int>.filled(SCALAR_INTS, 0));
    decodeScalar(k, 0, nA);

    // Compute the point R' = nS * B + nA * A, where B is the standard base point and A is the public key.
    final pR = PointAccum.create();
    scalarMultStraussVar(nS, nA, pA, pR);

    // Encode the point R' and check if it matches the R component of the signature.
    final check = Uint8List(POINT_BYTES);
    encodePoint(pR, check, 0);
    return const ListEquality().equals(check, R);
  }

  /// Signs a message using the Ed25519 digital signature algorithm.
  ///
  /// This function takes a secret key [sk], a [message], and optional parameters [pk], [pkOffset], and [context].
  /// If [pk] and [pkOffset] are provided, the function signs the message using the private key corresponding to the given public key.
  /// If [context] is provided, it is used as additional context information during the signing process.
  /// If phFlag is set manually it will be used instead of the default value (0x00)
  ///
  /// Throws an `ArgumentError` if any of the required parameters are null or if `messageLength` is non-positive.
  void sign({
    required Uint8List sk,
    required int skOffset,
    required Uint8List message,
    required int messageOffset,
    required int messageLength,
    required Uint8List signature,
    required int signatureOffset,
    Uint8List? pk,
    int? pkOffset,
    Uint8List? context,
    int? phflag,
  }) {
    assert(sk.isNotEmpty, 'Secret key must not be empty');
    assert(skOffset >= 0, 'Secret key offset must be non-negative');
    assert(skOffset + SECRET_KEY_SIZE <= sk.length,
        'Secret key offset and length exceed the bounds of the secret key');
    // assert(message.isEmpty, 'Message must not be empty');
    assert(messageOffset >= 0, 'Message offset must be non-negative');
    assert(messageLength >= 0, 'Message length must be non-negative');
    assert(messageOffset + messageLength <= message.length,
        'Offset and Length exceed the bounds of the message');
    assert(signature.isNotEmpty, 'Signature must not be Empty');
    assert(signatureOffset >= 0, 'Signature offset must be non-negative');
    assert(signatureOffset + SIGNATURE_SIZE <= signature.length,
        'Offset and length exceed the bounds of the signature');

    /// PORT NOTE: This is the Dart implementation of the `sign` function in the BramblSC library.
    /// The original implementation had 4 instances of the sign Function with different parameters.
    /// this also facilitates the Prehash Functionality.
    /// this has been replaced with a single function with optional parameters.
    final phf = phflag ?? 0x00; // facilitate Prehash Functionality
    final ctx = context ?? Uint8List(0);

    if (pk != null && pkOffset != null) {
      // do signing with pk and context
      implSignWithPrivateKeyAndPublicKey(
        sk,
        skOffset,
        pk,
        pkOffset,
        ctx,
        phf,
        message,
        messageOffset,
        messageLength,
        signature,
        signatureOffset,
      );
    } else {
      implSignWithPrivateKey(
        sk,
        skOffset,
        ctx,
        phf,
        message,
        messageOffset,
        messageLength,
        signature,
        signatureOffset,
      );
    }
  }

  /// Signs a prehashed message using the Ed25519 algorithm.
  /// demands that either [phSha] or [ph] is not [null].
  /// Only pass through a value to one of them or else this will raise [ArgumentError]
  ///
  /// Throws an [ArgumentError] if both [phSha] and [ph] are [null].
  /// Throws an [ArgumentError] if the prehashed message is not valid.
  void signPrehash({
    required Uint8List sk,
    required int skOffset,
    Uint8List? pk,
    int? pkOffset,
    required Uint8List context,
    SHA512? phSha,
    Uint8List? ph,
    int? phOffset,
    required Uint8List signature,
    required int signatureOffset,
  }) {
    // PH MUST BE EITHER [SHA512] or [UInt8List]
    const phflag = 0x01; // facilitate Prehash Functionality
    final phOff = phOffset ?? 0;

    if (phSha == null && ph == null) throw ArgumentError('Prehash is null');
    if (phSha == null && ph != null) {
      sign(
          sk: sk,
          skOffset: skOffset,
          pk: pk,
          pkOffset: pkOffset,
          context: context,
          phflag: phflag, // let Sign know that this is a Prehash
          message: ph,
          messageOffset: phOff,
          messageLength: PREHASH_SIZE,
          signature: signature,
          signatureOffset: signatureOffset);
    } else if (phSha != null && ph == null) {
      final m = Uint8List(PREHASH_SIZE);
      if (PREHASH_SIZE != phSha.doFinal(m, 0)) {
        throw ArgumentError('Prehash Invalid');
      }
      sign(
        sk: sk,
        skOffset: skOffset,
        pk: pk,
        pkOffset: pkOffset,
        context: context,
        phflag: phflag, // let Sign know that this is a Prehash
        message: m,
        messageOffset: 0,
        messageLength: m.length,
        signature: signature,
        signatureOffset: signatureOffset,
      );
    } else {
      throw ArgumentError('PhSha and ph should not both be passed in');
    }
  }

  /// Verifies an Ed25519 signature.
  ///
  /// Returns `true` if the signature is valid, `false` otherwise.
  bool verify({
    required Uint8List signature,
    required int signatureOffset,
    required Uint8List pk,
    required int pkOffset,
    Uint8List? context,
    required Uint8List message,
    required int messageOffset,
    required int messageLength,
  }) {
    const phflag = 0x00;
    final ctx = context ?? Uint8List(0);

    return _implVerify(
      signature,
      signatureOffset,
      pk,
      pkOffset,
      ctx,
      phflag,
      message,
      messageOffset,
      messageLength,
    );
  }

  /// Verifies an Ed25519 signature of a prehashed message.
  ///
  /// demands that either [phSha] or [ph] is not [null].
  /// Only pass through a value to one of them or else this will raise [ArgumentError]
  ///
  /// Throws an [ArgumentError] if both [phSha] and [ph] are [null].
  ///
  /// Returns `true` if the signature is valid, `false` otherwise.
  bool verifyPrehash({
    required Uint8List signature,
    required int signatureOffset,
    required Uint8List pk,
    required int pkOffset,
    required Uint8List context,
    Uint8List? ph,
    SHA512? phSha,
    required int phOff,
  }) {
    const phflag = 0x01;

    if (phSha == null && ph == null) throw ArgumentError('Prehash is null');
    if (phSha == null && ph != null) {
      return _implVerify(
        signature,
        signatureOffset,
        pk,
        pkOffset,
        context,
        phflag,
        ph,
        phOff,
        PREHASH_SIZE,
      );
    } else if (phSha != null && ph == null) {
      final m = Uint8List(PREHASH_SIZE);
      if (PREHASH_SIZE != phSha.doFinal(m, 0)) {
        throw ArgumentError('Prehash as Sha Invalid');
      }
      return _implVerify(
        signature,
        signatureOffset,
        pk,
        pkOffset,
        context,
        phflag,
        m,
        0,
        m.length,
      );
    } else {
      throw ArgumentError('PhSha and ph should not both be passed in');
    }
  }
}
