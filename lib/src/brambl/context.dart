// import 'package:brambl_dart/src/brambl/validation/blake2b256_digest_interpreter.dart';
// import 'package:brambl_dart/src/brambl/validation/extended_ed25519_signature_interpreter.dart';
// import 'package:brambl_dart/src/common/functional/either.dart';
// import 'package:brambl_dart/src/quivr/algebras/digest_verifier.dart';
// import 'package:brambl_dart/src/quivr/algebras/signature_verifier.dart';
// import 'package:brambl_dart/src/quivr/common/parsable_data_interface.dart';
// import 'package:brambl_dart/src/quivr/runtime/dynamic_context.dart';
// import 'package:fixnum/fixnum.dart';
// import 'package:topl_common/proto/brambl/models/datum.pb.dart';
// import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
// import 'package:topl_common/proto/quivr/models/shared.pb.dart';

// /// A Verification Context opinionated to the Topl context.
// /// [signableBytes], [currentTick] and the datums are dynamic.
// class Context extends DynamicContext {
//   final IoTransaction tx;
//   final Int64 curTick;
//   final Option<Datum> Function(String) heightDatums;

//   /// Constructs a new [Context] instance.
//   Context(this.tx, this.curTick, this.heightDatums)
//       : super(
//           datum,
//           _interfaces,
//           _signingRoutines,
//           _hashingRoutines,
//           SignableBytes.fromBuffer(tx.writeToBuffer()),
//           curTick,
//           _heightOf,
//         );

//    static const Map<String, DigestVerifier> _hashingRoutines = {'Blake2b256': Blake2b256DigestInterpreter()};

//    static const Map<String, SignatureVerifier> _signingRoutines = {'ExtendedEd25519': ExtendedEd25519SignatureInterpreter()};

//   static const Map<String, ParsableDataInterface> _interfaces = {}; // Arbitrary

//   static const Future<SignableBytes> signableBytes = tx.signable;

//   Option<Datum> Function(String) get datums => heightDatums;

//   /// Returns the height of the specified label.
//   static Option<Int64> _heightOf(String label,  Option<Datum> Function(String) heightDatums) {
//     final datum = heightDatums(label);
//     return datum.isDefined ? Some(datum.value.header.event.height) : None();
//   }
// }

import 'package:brambl_dart/src/brambl/validation/blake2b256_digest_interpreter.dart';
import 'package:brambl_dart/src/brambl/validation/extended_ed25519_signature_interpreter.dart';
import 'package:brambl_dart/src/quivr/algebras/digest_verifier.dart';
import 'package:brambl_dart/src/quivr/algebras/signature_verifier.dart';
import 'package:brambl_dart/src/quivr/runtime/dynamic_context.dart';
import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../quivr/common/parsable_data_interface.dart';

final Map<String, DigestVerifier> _hashingRoutines = {
  'Blake2b256': Blake2b256DigestInterpreter()
};
final Map<String, SignatureVerifier> _signingRoutines = {
  'ExtendedEd25519': ExtendedEd25519SignatureInterpreter()
};
final Map<String, ParsableDataInterface> _interfaces = {}; // Arbitrary

Int64? _heightOf(String label, Datum? Function(String) heightDatums) {
  final datum = heightDatums(label);
  if (datum != null) {
    return datum.header.event.height;
  } else {
    return null;
  }
}

class Context extends DynamicContext {
  final IoTransaction tx;
  final Int64 curTick;
  final Map<String, Datum?> heightDatums;
  Context(this.tx, this.curTick, this.heightDatums)
      : super(heightDatums, _interfaces, _signingRoutines, _hashingRoutines,
            SignableBytes.fromBuffer(tx.writeToBuffer()), curTick, _heightOf);
}
