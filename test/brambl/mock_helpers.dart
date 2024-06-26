import 'package:brambldart/brambldart.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
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

/// All protobuf returnables are frozen
/// This is to ensure that they are not mutated and are available for rebuild during testing

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

const mockSigningRoutine = 'ExtendedEd25519';

final mockSignatureProposition =
    Proposer.signatureProposer(mockSigningRoutine, ProtoConverters.keyPairToProto(mockChildKeyPair).vk)..freeze();

final mockSignature = Witness(
  value: ExtendedEd25519().sign(mockChildKeyPair.signingKey, fakeMsgBind.value.toUint8List()),
)..freeze();
final mockSignatureProof = Prover.signatureProver(mockSignature, fakeMsgBind)..freeze();

final mockPreimage = Preimage(input: 'secret'.toCodeUnitUint8List(), salt: 'salt'.toUtf8Uint8List())..freeze();

// Hardcoding Blake2b256
const mockDigestRoutine = 'Blake2b256';

final mockDigest = Digest(value: Blake2b256().hash((mockPreimage.input + mockPreimage.salt).toUint8List()))..freeze();
final mockDigestProposition = Proposer.digestProposer(mockDigestRoutine, mockDigest)..freeze();
final mockDigestProof = Prover.digestProver(mockPreimage, fakeMsgBind)..freeze();

const mockMin = 0;
const mockMax = 100;
const mockChain = 'header';
final mockTickProposition = Proposer.tickProposer(mockMin.toInt64, mockMax.toInt64)..freeze();
final mockTickProof = Prover.tickProver(fakeMsgBind)..freeze();

final mockHeightProposition = Proposer.heightProposer(mockChain, mockMin.toInt64, mockMax.toInt64)..freeze();
final mockHeightProof = Prover.heightProver(fakeMsgBind)..freeze();

final mockLockedProposition = Proposer.lockedProposer(null)..freeze();
final mockLockedProof = Prover.lockedProver()..freeze();

final txDatum = Datum_IoTransaction(
  event: Event_IoTransaction(
    schedule: Schedule(min: Int64.ZERO, max: Int64.MAX_VALUE, timestamp: DateTime.now().millisecondsSinceEpoch.toInt64),
    metadata: SmallData(),
  ),
)..freeze();

// Arbitrary Transaction that any new transaction can reference
final dummyTx = IoTransaction(datum: txDatum)..freeze();

final dummyTxIdentifier = TransactionId(value: dummyTx.sizedEvidence.digest.value)..freeze();

final dummyTxoAddress = TransactionOutputAddress(network: 0, ledger: 0, index: 0, id: dummyTxIdentifier)..freeze();

final quantity = Int128(value: BigInt.from(1).toUint8List())..freeze();

final lvlValue = Value(lvl: Value_LVL(quantity: quantity))..freeze();

final trivialOutLock = Lock(
    predicate:
        Lock_Predicate(challenges: [Challenge(revealed: Proposer.tickProposer(5.toInt64, 15.toInt64))], threshold: 1))
  ..freeze();

final trivialLockAddress =
    LockAddress(network: 0, ledger: 0, id: LockId(value: trivialOutLock.sizedEvidence.digest.value))..freeze();

final inPredicateLockFull = Lock_Predicate(
  challenges: [
    mockLockedProposition,
    mockDigestProposition,
    mockSignatureProposition,
    mockHeightProposition,
    mockTickProposition
  ].map((p) => Challenge(revealed: p)),
  threshold: 3,
)..freeze();

final inLockFull = Lock(predicate: inPredicateLockFull)..freeze();
final inLockFullAddress = LockAddress(network: 0, ledger: 0, id: LockId(value: inLockFull.sizedEvidence.digest.value))
  ..freeze();

final inPredicateLockFullAttestation = Attestation_Predicate(
  lock: inPredicateLockFull,
  responses: [
    mockLockedProof,
    mockDigestProof,
    mockSignatureProof,
    mockHeightProof,
    mockTickProof,
  ],
)..freeze();

final nonEmptyAttestation = Attestation(predicate: inPredicateLockFullAttestation)..freeze();

final output = UnspentTransactionOutput(address: trivialLockAddress, value: lvlValue)..freeze();

final fullOutput = UnspentTransactionOutput(address: inLockFullAddress, value: lvlValue)..freeze();

final attFull = Attestation(
    predicate: Attestation_Predicate(
        lock: inPredicateLockFull, responses: List.filled(inPredicateLockFull.challenges.length, Proof())))
  ..freeze();

final inputFull = SpentTransactionOutput(address: dummyTxoAddress, attestation: attFull, value: lvlValue)..freeze();

final txFull = IoTransaction(inputs: [inputFull], outputs: [output], datum: txDatum)..freeze();

final mockVks = [
  mockChildKeyPair.verificationKey,
  ExtendedEd25519().deriveKeyPairFromSeed(List.filled(96, 1).toUint8List()).verificationKey,
];

final mockSeriesPolicy = SeriesPolicy(label: 'Mock Series Policy', registrationUtxo: dummyTxoAddress)..freeze();
final mockGroupPolicy = GroupPolicy(label: 'Mock Group Policy', registrationUtxo: dummyTxoAddress)..freeze();

final toplValue = Value(topl: Value_TOPL(quantity: quantity));
final seriesValue = Value(series: Value_Series(seriesId: mockSeriesPolicy.computeId, quantity: quantity))..freeze();
final groupValue = Value(group: Value_Group(groupId: mockGroupPolicy.computeId, quantity: quantity))..freeze();

final assetGroupSeries = Value(
  asset: Value_Asset(groupId: mockGroupPolicy.computeId, seriesId: mockSeriesPolicy.computeId, quantity: quantity),
)..freeze();

final assetGroupSeriesImmutable =
    assetGroupSeries.rebuild((p0) => p0.asset.quantityDescriptor = QuantityDescriptorType.IMMUTABLE)..freeze();

final assetGroupSeriesFractionable =
    assetGroupSeries.rebuild((p0) => p0.asset.quantityDescriptor = QuantityDescriptorType.FRACTIONABLE)..freeze();

final assetGroupSeriesAccumulator =
    assetGroupSeries.rebuild((p0) => p0.asset.quantityDescriptor = QuantityDescriptorType.ACCUMULATOR)..freeze();

/// awkward rebuilding because rebuild does not allow all fields to be rebuilt.
final assetGroup = assetGroupSeries.rebuild((p0) {
  final newAsset = p0.asset.rebuild((p1) => p1.fungibility = FungibilityType.GROUP);
  p0.asset = newAsset;
})
  ..freeze();

final assetGroupImmutable = assetGroup.rebuild((p0) => p0.asset.quantityDescriptor = QuantityDescriptorType.IMMUTABLE)
  ..freeze();
final assetGroupFractionable =
    assetGroup.rebuild((p0) => p0.asset.quantityDescriptor = QuantityDescriptorType.FRACTIONABLE)..freeze();
final assetGroupAccumulator =
    assetGroup.rebuild((p0) => p0.asset.quantityDescriptor = QuantityDescriptorType.ACCUMULATOR)..freeze();

/// awkward rebuilding because rebuild does not allow all fields to be rebuilt.
final assetSeries = assetGroupSeries.rebuild((p0) {
  final newAsset = p0.asset.rebuild((p1) => p1.fungibility = FungibilityType.SERIES);
  p0.asset = newAsset;
})
  ..freeze();

final assetSeriesImmutable = assetSeries.rebuild((p0) => p0.asset.quantityDescriptor = QuantityDescriptorType.IMMUTABLE)
  ..freeze();
final assetSeriesFractionable =
    assetSeries.rebuild((p0) => p0.asset.quantityDescriptor = QuantityDescriptorType.FRACTIONABLE)..freeze();
final assetSeriesAccumulator =
    assetSeries.rebuild((p0) => p0.asset.quantityDescriptor = QuantityDescriptorType.ACCUMULATOR)..freeze();


/// todo: missing some helpers here: