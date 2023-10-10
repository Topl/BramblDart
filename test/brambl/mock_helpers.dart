import 'package:brambl_dart/brambl_dart.dart';
import 'package:brambl_dart/src/brambl/common/contains_evidence.dart';
import 'package:brambl_dart/src/brambl/syntax/group_policy_syntax.dart';
import 'package:brambl_dart/src/brambl/syntax/series_policy_syntax.dart';
import 'package:brambl_dart/src/crypto/generation/bip32_index.dart';
import 'package:brambl_dart/src/crypto/hash/hash.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519.dart';
import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/box/asset.pbenum.dart';
import 'package:topl_common/proto/brambl/models/box/attestation.pb.dart';
import 'package:topl_common/proto/brambl/models/box/challenge.pb.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/brambl/models/event.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';
import 'package:topl_common/proto/brambl/models/indices.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/schedule.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/spent_transaction_output.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/unspent_transaction_output.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

// class MockHelpers {
final fakeMsgBind = SignableBytes(value: 'transaction binding'.toCodeUnitUint8List());

final mockIndices = Indices(x: 0, y: 0, z: 0);
// Hardcoding ExtendedEd25519
final mockMainKeyPair = ExtendedEd25519().deriveKeyPairFromSeed(List.filled(96, 0).toUint8List());

final mockChildKeyPair = ExtendedEd25519().deriveKeyPairFromChildPath(
  mockMainKeyPair.signingKey,
  [
    HardenedIndex(mockIndices.x),
    SoftIndex(mockIndices.y),
    SoftIndex(mockIndices.z),
  ],
);

final mockSigningRoutine = 'ExtendedEd25519';

final mockSignatureProposition =
    Proposer.signatureProposer(mockSigningRoutine, ProtoConverters.keyPairToProto(mockChildKeyPair).vk);

final mockSignature = Witness(
  value: ExtendedEd25519().sign(mockChildKeyPair.signingKey, fakeMsgBind.value.toUint8List()),
);
final mockSignatureProof = Prover.signatureProver(mockSignature, fakeMsgBind);

final mockPreimage = Preimage(input: 'secret'.toCodeUnitUint8List(), salt: 'salt'.toUtf8Uint8List());

// Hardcoding Blake2b256
final mockDigestRoutine = 'Blake2b256';

final mockDigest = Digest(value: Blake2b256().hash((mockPreimage.input + mockPreimage.salt).toUint8List()));
final mockDigestProposition = Proposer.digestProposer(mockDigestRoutine, mockDigest);
final mockDigestProof = Prover.digestProver(mockPreimage, fakeMsgBind);

final mockMin = 0;
final mockMax = 100;
final mockChain = 'header';
final mockTickProposition = Proposer.tickProposer(mockMin.toInt64, mockMax.toInt64);
final mockTickProof = Prover.tickProver(fakeMsgBind);

final mockHeightProposition = Proposer.heightProposer(mockChain, mockMin.toInt64, mockMax.toInt64);
final mockHeightProof = Prover.heightProver(fakeMsgBind);

final mockLockedProposition = Proposer.lockedProposer(null);
final mockLockedProof = Prover.lockedProver();

final txDatum = Datum_IoTransaction(
  event: Event_IoTransaction(
    schedule: Schedule(min: Int64.ZERO, max: Int64.MAX_VALUE, timestamp: DateTime.now().millisecondsSinceEpoch.toInt64),
    metadata: SmallData(),
  ),
);

// Arbitrary Transaction that any new transaction can reference
final dummyTx = IoTransaction(datum: txDatum);

final dummyTxIdentifier = TransactionId(value: dummyTx.sizedEvidence.digest.value);

final dummyTxoAddress = TransactionOutputAddress(network: 0, ledger: 0, index: 0, id: dummyTxIdentifier);

final quantity = Int128(value: BigInt.from(1).toUint8List());

final lvlValue = Value(lvl: Value_LVL(quantity: quantity));

final trivialOutLock = Lock(
    predicate:
        Lock_Predicate(challenges: [Challenge(revealed: Proposer.tickProposer(5.toInt64, 15.toInt64))], threshold: 1));

final trivialLockAddress =
    LockAddress(network: 0, ledger: 0, id: LockId(value: trivialOutLock.sizedEvidence.digest.value));

final inPredicateLockFull = Lock_Predicate(
  challenges: [
    mockLockedProposition,
    mockDigestProposition,
    mockSignatureProposition,
    mockHeightProposition,
    mockTickProposition
  ].map((p) => Challenge(revealed: p)),
  threshold: 3,
);

final inLockFull = Lock(predicate: inPredicateLockFull);
final inLockFullAddress = LockAddress(network: 0, ledger: 0, id: LockId(value: inLockFull.sizedEvidence.digest.value));

final inPredicateLockFullAttestation = Attestation_Predicate(
  lock: inPredicateLockFull,
  responses: [
    mockLockedProof,
    mockDigestProof,
    mockSignatureProof,
    mockHeightProof,
    mockTickProof,
  ],
);

final nonEmptyAttestation = Attestation(predicate: inPredicateLockFullAttestation);

final output = UnspentTransactionOutput(address: trivialLockAddress, value: lvlValue);

final fullOutput = UnspentTransactionOutput(address: inLockFullAddress, value: lvlValue);

final attFull = Attestation(
    predicate: Attestation_Predicate(
        lock: inPredicateLockFull, responses: List.filled(inPredicateLockFull.challenges.length, Proof())));

final inputFull = SpentTransactionOutput(address: dummyTxoAddress, attestation: attFull, value: lvlValue);

final txFull = IoTransaction(inputs: [inputFull], outputs: [output], datum: txDatum);

final mockVks = [
  mockChildKeyPair.verificationKey,
  ExtendedEd25519().deriveKeyPairFromSeed(List.filled(96, 1).toUint8List()).verificationKey,
];

final mockSeriesPolicy = SeriesPolicy(label: 'Mock Series Policy', registrationUtxo: dummyTxoAddress);
final mockGroupPolicy = GroupPolicy(label: 'Mock Group Policy', registrationUtxo: dummyTxoAddress);

final seriesValue = Value(series: Value_Series(seriesId: mockSeriesPolicy.computeId, quantity: quantity));
final groupValue = Value(group: Value_Group(groupId: mockGroupPolicy.computeId, quantity: quantity));

final assetGroupSeries = Value(
  asset: Value_Asset(groupId: mockGroupPolicy.computeId, seriesId: mockSeriesPolicy.computeId, quantity: quantity),
);

final assetGroupSeriesImmutable = assetGroupSeries..asset.quantityDescriptor = QuantityDescriptorType.IMMUTABLE;

final assetGroupSeriesFractionable = assetGroupSeries..asset.quantityDescriptor = QuantityDescriptorType.FRACTIONABLE;

final assetGroupSeriesAccumulator = assetGroupSeries..asset.quantityDescriptor = QuantityDescriptorType.ACCUMULATOR;

final assetGroup = assetGroupSeries..asset.fungibility = FungibilityType.GROUP;

final assetGroupImmutable = assetGroup..asset.quantityDescriptor = QuantityDescriptorType.IMMUTABLE;
final assetGroupFractionable = assetGroup..asset.quantityDescriptor = QuantityDescriptorType.FRACTIONABLE;
final assetGroupAccumulator = assetGroup..asset.quantityDescriptor = QuantityDescriptorType.ACCUMULATOR;

final assetSeries = assetGroupSeries..asset.fungibility = FungibilityType.SERIES;

final assetSeriesImmutable = assetSeries..asset.quantityDescriptor = QuantityDescriptorType.IMMUTABLE;
final assetSeriesFractionable = assetSeries..asset.quantityDescriptor = QuantityDescriptorType.FRACTIONABLE;
final assetSeriesAccumulator = assetSeries..asset.quantityDescriptor = QuantityDescriptorType.ACCUMULATOR;
