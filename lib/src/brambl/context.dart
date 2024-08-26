import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';

import '../quivr/algebras/digest_verifier.dart';
import '../quivr/algebras/signature_verifier.dart';
import '../quivr/common/parsable_data_interface.dart';
import '../quivr/runtime/dynamic_context.dart';
import 'common/contains_signable.dart';
import 'validation/blake2b256_digest_interpreter.dart';
import 'validation/extended_ed25519_signature_interpreter.dart';
import 'validation/sha256_digest_interpeter.dart';

final Map<String, DigestVerifier> _hashingRoutines = {
  'Blake2b256': Blake2b256DigestInterpreter(),
  'Sha256': Sha256DigestInterpreter()
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
  Context(this.tx, this.curTick, Map<String, Datum?> heightDatums)
      : super(
            heightDatums,
            _interfaces,
            _signingRoutines,
            _hashingRoutines,
            tx.signable,
            curTick,
            (label) => _heightOf(label, (key) => heightDatums[key]));
  final IoTransaction tx;
  final Int64 curTick;
}
