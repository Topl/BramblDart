import 'dart:typed_data';

import 'package:brambldart/brambldart.dart';
import 'package:brambldart/src/quivr/algebras/digest_verifier.dart';
import 'package:brambldart/src/quivr/algebras/signature_verifier.dart';
import 'package:brambldart/src/quivr/common/parsable_data_interface.dart';
import 'package:brambldart/src/quivr/common/quivr_result.dart';
import 'package:brambldart/src/quivr/runtime/dynamic_context.dart';
import 'package:brambldart/src/quivr/runtime/quivr_runtime_error.dart';
import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/brambl/models/event.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import 'very_secure_signature_routine.dart';

class MockHelpers {
  static const heightString = "height";
  static const signatureString = "verySecure";
  static const hashString = "blake2b256";
  static const saltString = "I am a digest";
  static const preimageString = "I am a preimage";

  static final signableBytes = SignableBytes()
    ..value = Uint8List.fromList("someSignableBytes".codeUnits);

  static DynamicContext dynamicContext(Proposition proposition, Proof proof) {
    final Map<String, Datum> mapOfDatums = {
      heightString: Datum()
        ..header = Datum_Header(event: Event_Header(height: Int64(999)))
    };

    final Map<String, ParsableDataInterface> mapOfInterfaces = {};

    final Map<String, SignatureVerifier> mapOfSigningRoutines = {
      signatureString: SignatureVerifier((v) {
        if (VerySecureSignatureRoutine.verify(
            v.signature.value.toUint8List(),
            v.message.value.toUint8List(),
            v.verificationKey.ed25519.value.toUint8List())) {
          return QuivrResult<SignatureVerification>.right(v);
        } else {
          return QuivrResult<SignatureVerification>.left(
              ValidationError.messageAuthorizationFailure(proof: proof));
        }
      })
    };

    final Map<String, DigestVerifier> mapOfHashingRoutines = {
      hashString: DigestVerifier((v) {
        final test = Blake2b256()
            .hash(Uint8List.fromList(v.preimage.input + v.preimage.salt));
        if (v.digest.value.toUint8List() == test) {
          return QuivrResult<DigestVerification>.right(v);
        } else {
          return QuivrResult<DigestVerification>.left(
              ValidationError.lockedPropositionIsUnsatisfiable(
                  context: v.toString()));
        }
      })
    };

    final currentTick = Int64(999);

    Int64? heightOf(String label) {
      final datum = mapOfDatums[label];
      if (datum != null) {
        final header = datum.header;
        final eventHeader = header.event;
        return eventHeader.height;
      }
      return null;
    }

    return DynamicContext(mapOfDatums, mapOfInterfaces, mapOfSigningRoutines,
        mapOfHashingRoutines, signableBytes, currentTick, heightOf);
  }
}
