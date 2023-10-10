import 'dart:typed_data';

import 'package:brambl_dart/src/brambl/common/tags.dart';
import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/common/types/byte_string.dart';
import 'package:brambl_dart/src/quivr/tokens.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/box/asset.pbenum.dart';
import 'package:topl_common/proto/brambl/models/box/attestation.pb.dart';
import 'package:topl_common/proto/brambl/models/box/box.pb.dart';
import 'package:topl_common/proto/brambl/models/box/challenge.pb.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/brambl/models/common.pb.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/brambl/models/event.pb.dart';
import 'package:topl_common/proto/brambl/models/evidence.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/schedule.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/spent_transaction_output.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/unspent_transaction_output.pb.dart';
import 'package:topl_common/proto/consensus/models/operational_certificate.pb.dart';
import 'package:topl_common/proto/consensus/models/staking.pb.dart';
import 'package:topl_common/proto/google/protobuf/struct.pb.dart' as str;
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

/// provides factory methods for creating [ContainsImmutable] [ImmutableBytes] objects
class ContainsImmutable {
  final ImmutableBytes immutableBytes;

  const ContainsImmutable(this.immutableBytes);

  // Processes any list, potentially funky problems with nested lists.
  factory ContainsImmutable.list(List list) {
    return list.asMap().entries.fold(
          ContainsImmutable.empty(),
          (acc, entry) => acc + ContainsImmutable.int(entry.key) + ContainsImmutable.apply(entry.value),
        );
  }

  factory ContainsImmutable.empty() {
    return ContainsImmutable(ImmutableBytes());
  }

  /// Creates an ContainsImmutable object from a [int]
  factory ContainsImmutable.int(int i) => i.toBytes.immutable;

  /// Creates an ContainsImmutable object from a [String]
  factory ContainsImmutable.string(String string) => string.toUtf8Uint8List().immutable;

  /// Creates an ContainsImmutable object from a [Uint8List]
  factory ContainsImmutable.struct(str.Struct struct) => struct.writeToBuffer().immutable;

  /// Wrapper object for ByteString
  factory ContainsImmutable.byteString(ByteString byteString) => byteString.bytes.immutable;

  /// Creates an [ContainsImmutable] from a [Int64]
  factory ContainsImmutable.int64(Int64 i) => i.toBytes().immutable;

  /// Creates an [ContainsImmutable] from a pb [Int128]
  factory ContainsImmutable.int128(Int128 i) => i.value.immutable;

  /// Ensures an [ImmutableBytes] from a nullable [ContainsImmutable]
  factory ContainsImmutable.nullable(ContainsImmutable? nullable) => nullable ?? [0xff].immutable;

  /// Ensures an [ImmutableBytes] from a optional [ContainsImmutable]
  factory ContainsImmutable.option(Option<ContainsImmutable> option) =>
      option.isDefined ? option.value : [0xff].immutable;

  /// Creates an [ImmutableBytes] from a [SmallData]
  factory ContainsImmutable.small(SmallData s) => s.value.immutable;

  /// Creates an [ImmutableBytes] from a [Root]
  factory ContainsImmutable.root(Root r) => r.value.immutable;

  /// Creates an [ImmutableBytes] from a [VerificationKey]
  factory ContainsImmutable.verificationKey(VerificationKey vk) {
    if (vk.hasEd25519()) {
      return ContainsImmutable.ed25519VerificationKey(vk.ed25519);
    } else if (vk.hasExtendedEd25519()) {
      return ContainsImmutable.extendedEd25519VerificationKey(vk.extendedEd25519);
    } else {
      apply(null);
      throw Exception('Invalid VerificationKey type ${vk.runtimeType}');
    }
  }

  /// Creates an [ImmutableBytes] from a [VerificationKey_Ed25519Vk]
  factory ContainsImmutable.ed25519VerificationKey(VerificationKey_Ed25519Vk vk) => vk.value.immutable;

  /// Creates an [ImmutableBytes] from a [VerificationKey_ExtendedEd25519Vk]
  factory ContainsImmutable.extendedEd25519VerificationKey(VerificationKey_ExtendedEd25519Vk vkey) =>
      vkey.vk.value.immutable + vkey.chainCode.immutable;

  /// Creates an [ImmutableBytes] from a [Witness]
  factory ContainsImmutable.witness(Witness w) => w.value.immutable;

  /// Creates an [ImmutableBytes] from a [Datum]
  factory ContainsImmutable.datum(Datum d) {
    if (d.hasEon()) {
      return ContainsImmutable.eonDatum(d.eon);
    } else if (d.hasEra()) {
      return ContainsImmutable.eraDatum(d.era);
    } else if (d.hasEpoch()) {
      return ContainsImmutable.epochDatum(d.epoch);
    } else if (d.hasHeader()) {
      return ContainsImmutable.headerDatum(d.header);
    } else if (d.hasIoTransaction()) {
      return ContainsImmutable.ioTransactionDatum(d.ioTransaction);
    } else if (d.hasGroupPolicy()) {
      return ContainsImmutable.groupPolicyDatum(d.groupPolicy);
    } else if (d.hasSeriesPolicy()) {
      return ContainsImmutable.seriesPolicyDatum(d.seriesPolicy);
    } else {
      throw Exception('Invalid Datum type ${d.runtimeType}');
    }
  }

  factory ContainsImmutable.eonDatum(Datum_Eon eon) => ContainsImmutable.eonEvent(eon.event);
  factory ContainsImmutable.eraDatum(Datum_Era era) => ContainsImmutable.eraEvent(era.event);
  factory ContainsImmutable.epochDatum(Datum_Epoch epoch) => ContainsImmutable.epochEvent(epoch.event);
  factory ContainsImmutable.headerDatum(Datum_Header header) => ContainsImmutable.headerEvent(header.event);
  factory ContainsImmutable.ioTransactionDatum(Datum_IoTransaction ioTransaction) =>
      ContainsImmutable.iotxEventImmutable(ioTransaction.event);
  factory ContainsImmutable.groupPolicyDatum(Datum_GroupPolicy gp) => ContainsImmutable.groupPolicyEvent(gp.event);
  factory ContainsImmutable.seriesPolicyDatum(Datum_SeriesPolicy sp) => ContainsImmutable.seriesPolicyEvent(sp.event);

  factory ContainsImmutable.ioTransaction(IoTransaction iotx) =>
      ContainsImmutable.list(iotx.inputs) +
      ContainsImmutable.list(iotx.outputs) +
      ContainsImmutable.ioTransactionDatum(iotx.datum);

  factory ContainsImmutable.iotxSchedule(Schedule schedule) =>
      ContainsImmutable.int64(schedule.min) + ContainsImmutable.int64(schedule.max);

  factory ContainsImmutable.spentOutput(SpentTransactionOutput stxo) =>
      ContainsImmutable.transactionOutputAddress(stxo.address) +
      ContainsImmutable.attestation(stxo.attestation) +
      ContainsImmutable.value(stxo.value);

  factory ContainsImmutable.unspentOutput(UnspentTransactionOutput utxo) =>
      ContainsImmutable.lockAddress(utxo.address) + ContainsImmutable.value(utxo.value);

  factory ContainsImmutable.box(Box box) => ContainsImmutable.lock(box.lock) + ContainsImmutable.value(box.value);

  factory ContainsImmutable.value(Value v) {
    if (v.hasLvl()) {
      return ContainsImmutable.lvlValue(v.lvl);
    } else if (v.hasTopl()) {
      return ContainsImmutable.toplValue(v.topl);
    } else if (v.hasAsset()) {
      return ContainsImmutable.assetValue(v.asset);
    } else {
      return [0].immutable;
    }
  }

  factory ContainsImmutable.lvlValue(Value_LVL v) => ContainsImmutable.int128(v.quantity);

  factory ContainsImmutable.toplValue(Value_TOPL v) =>
      ContainsImmutable.int128(v.quantity) + ContainsImmutable.stakingRegistration(v.registration);

  factory ContainsImmutable.assetValue(Value_Asset asset) =>
      ContainsImmutable.groupIdentifier(asset.groupId) +
      ContainsImmutable.seriesIdValue(asset.seriesId) +
      ContainsImmutable.int128(asset.quantity) +
      asset.groupAlloy.value.immutable +
      asset.seriesAlloy.value.immutable +
      ContainsImmutable.fungibility(asset.fungibility) +
      ContainsImmutable.quantityDescriptor(asset.quantityDescriptor) +
      ContainsImmutable.struct(asset.ephemeralMetadata) +
      asset.commitment.value.immutable;

  factory ContainsImmutable.seriesValue(Value_Series _) =>
      ContainsImmutable.seriesIdValue(_.seriesId) +
      ContainsImmutable.int128(_.quantity) +
      ContainsImmutable.int(_.tokenSupply.value) +
      ContainsImmutable.quantityDescriptor(_.quantityDescriptor) +
      ContainsImmutable.fungibility(_.fungibility);

  factory ContainsImmutable.groupValue(Value_Group _) =>
      ContainsImmutable.groupIdentifier(_.groupId) +
      ContainsImmutable.int128(_.quantity) +
      ContainsImmutable.seriesIdValue(_.fixedSeries);

  factory ContainsImmutable.fungibility(FungibilityType _) => ContainsImmutable.int(_.value);

  factory ContainsImmutable.quantityDescriptor(QuantityDescriptorType _) => ContainsImmutable.int(_.value);

  factory ContainsImmutable.stakingAddress(StakingAddress v) => v.value.immutable;

  factory ContainsImmutable.evidence(Evidence e) => ContainsImmutable.digest(e.digest);

  factory ContainsImmutable.digest(Digest d) => d.value.immutable;

  factory ContainsImmutable.preimage(Preimage pre) => pre.input.immutable + pre.salt.immutable;

  factory ContainsImmutable.accumulatorRoot32Identifier(AccumulatorRootId id) =>
      ContainsImmutable.string(Identifier.accumulatorRoot32) + id.value.immutable;

  factory ContainsImmutable.boxLock32Identifier(LockId id) =>
      ContainsImmutable.string(Identifier.lock32) + id.value.immutable;

  factory ContainsImmutable.transactionIdentifier(TransactionId id) =>
      ContainsImmutable.string(Identifier.ioTransaction32) + id.value.immutable;

  factory ContainsImmutable.groupIdentifier(GroupId id) =>
      ContainsImmutable.string(Identifier.group32) + id.value.immutable;

  factory ContainsImmutable.seriesIdValue(SeriesId sid) =>
      ContainsImmutable.string(Tags.series32) + sid.value.immutable;

  factory ContainsImmutable.transactionOutputAddress(TransactionOutputAddress v) =>
      ContainsImmutable.int(v.network) +
      ContainsImmutable.int(v.ledger) +
      ContainsImmutable.int(v.index) +
      ContainsImmutable.transactionIdentifier(v.id);

  factory ContainsImmutable.lockAddress(LockAddress v) =>
      ContainsImmutable.int(v.network) + ContainsImmutable.int(v.ledger) + ContainsImmutable.boxLock32Identifier(v.id);

  // TODO: figure out why witness is List<List<Int>>
  factory ContainsImmutable.signatureKesSum(SignatureKesSum v) =>
      v.verificationKey.immutable + v.signature.immutable + ContainsImmutable.list(v.witness);

  factory ContainsImmutable.signatureKesProduct(SignatureKesProduct v) =>
      ContainsImmutable.signatureKesSum(v.superSignature) +
      ContainsImmutable.signatureKesSum(v.subSignature) +
      v.subRoot.immutable;

  factory ContainsImmutable.stakingRegistration(StakingRegistration v) =>
      ContainsImmutable.signatureKesProduct(v.signature) + ContainsImmutable.stakingAddress(v.address);

  factory ContainsImmutable.predicateLock(Lock_Predicate predicate) =>
      ContainsImmutable.int(predicate.threshold) + ContainsImmutable.list(predicate.challenges);

  factory ContainsImmutable.imageLock(Lock_Image image) =>
      ContainsImmutable.int(image.threshold) + ContainsImmutable.list(image.leaves);

  factory ContainsImmutable.commitmentLock(Lock_Commitment commitment) =>
      ContainsImmutable.int(commitment.threshold) +
      ContainsImmutable.int(commitment.root.value.length) +
      ContainsImmutable.accumulatorRoot32Identifier(commitment.root);

  factory ContainsImmutable.lock(Lock lock) {
    if (lock.hasPredicate()) {
      return ContainsImmutable.predicateLock(lock.predicate);
    } else if (lock.hasImage()) {
      return ContainsImmutable.imageLock(lock.image);
    } else if (lock.hasCommitment()) {
      return ContainsImmutable.commitmentLock(lock.commitment);
    } else {
      throw Exception('Invalid Lock type ${lock.runtimeType}');
    }
  }

  factory ContainsImmutable.predicateAttestation(Attestation_Predicate attestation) =>
      ContainsImmutable.predicateLock(attestation.lock) + ContainsImmutable.list(attestation.responses);

  factory ContainsImmutable.imageAttestation(Attestation_Image attestation) =>
      ContainsImmutable.imageLock(attestation.lock) +
      ContainsImmutable.list(attestation.known) +
      ContainsImmutable.list(attestation.responses);

  factory ContainsImmutable.commitmentAttestation(Attestation_Commitment attestation) =>
      ContainsImmutable.commitmentLock(attestation.lock) +
      ContainsImmutable.list(attestation.known) +
      ContainsImmutable.list(attestation.responses);

  factory ContainsImmutable.attestation(Attestation attestation) {
    if (attestation.hasPredicate()) {
      return ContainsImmutable.predicateAttestation(attestation.predicate);
    } else if (attestation.hasImage()) {
      return ContainsImmutable.imageAttestation(attestation.image);
    } else if (attestation.hasCommitment()) {
      return ContainsImmutable.commitmentAttestation(attestation.commitment);
    } else {
      return ContainsImmutable.empty();
    }
  }

  factory ContainsImmutable.transactionInputAddressContains(TransactionInputAddress address) =>
      ContainsImmutable.int(address.network) +
      ContainsImmutable.int(address.ledger) +
      ContainsImmutable.int(address.index) +
      ContainsImmutable.transactionIdentifier(address.id);

  factory ContainsImmutable.previousPropositionChallengeContains(Challenge_PreviousProposition p) =>
      ContainsImmutable.transactionInputAddressContains(p.address) + ContainsImmutable.int(p.index);

  factory ContainsImmutable.challengeContains(Challenge c) {
    if (c.hasRevealed()) {
      return ContainsImmutable.proposition(c.revealed);
    } else if (c.hasPrevious()) {
      return ContainsImmutable.previousPropositionChallengeContains(c.previous);
    } else {
      throw Exception('Invalid Challenge proposition');
    }
  }

  factory ContainsImmutable.eonEvent(Event_Eon event) =>
      ContainsImmutable.int64(event.beginSlot) + ContainsImmutable.int64(event.height);

  factory ContainsImmutable.eraEvent(Event_Era event) =>
      ContainsImmutable.int64(event.beginSlot) + ContainsImmutable.int64(event.height);

  factory ContainsImmutable.epochEvent(Event_Epoch event) =>
      ContainsImmutable.int64(event.beginSlot) + ContainsImmutable.int64(event.height);

  factory ContainsImmutable.headerEvent(Event_Header event) => ContainsImmutable.int64(event.height);

  factory ContainsImmutable.iotxEventImmutable(Event_IoTransaction event) =>
      ContainsImmutable.iotxSchedule(event.schedule) + ContainsImmutable.small(event.metadata);

  factory ContainsImmutable.groupPolicyEvent(Event_GroupPolicy _) =>
      ContainsImmutable.string(_.label) +
      ContainsImmutable.seriesIdValue(_.fixedSeries) +
      ContainsImmutable.transactionOutputAddress(_.registrationUtxo);

  factory ContainsImmutable.seriesPolicyEvent(Event_SeriesPolicy _) =>
      ContainsImmutable.string(_.label) +
      ContainsImmutable.int(_.tokenSupply.value) +
      ContainsImmutable.transactionOutputAddress(_.registrationUtxo) +
      ContainsImmutable.fungibility(_.fungibility) +
      ContainsImmutable.quantityDescriptor(_.quantityDescriptor);

  factory ContainsImmutable.eventImmutable(Event event) {
    if (event.hasEon()) {
      return ContainsImmutable.eonEvent(event.eon);
    } else if (event.hasEra()) {
      return ContainsImmutable.eraEvent(event.era);
    } else if (event.hasEpoch()) {
      return ContainsImmutable.epochEvent(event.epoch);
    } else if (event.hasHeader()) {
      return ContainsImmutable.headerEvent(event.header);
    } else if (event.hasIoTransaction()) {
      return ContainsImmutable.iotxEventImmutable(event.ioTransaction);
    } else if (event.hasGroupPolicy()) {
      return ContainsImmutable.groupPolicyEvent(event.groupPolicy);
    } else if (event.hasSeriesPolicy()) {
      return ContainsImmutable.seriesPolicyEvent(event.seriesPolicy);
    } else {
      throw Exception('Invalid Event type ${event.runtimeType}');
    }
  }

  factory ContainsImmutable.txBind(TxBind txBind) => txBind.value.immutable;

  factory ContainsImmutable.locked(Proposition_Locked _) => ContainsImmutable.string(Tokens.locked);

  factory ContainsImmutable.lockedProof(Proof_Locked _) => ContainsImmutable.empty();

  factory ContainsImmutable.digestProposition(Proposition_Digest p) =>
      ContainsImmutable.string(Tokens.digest) +
      ContainsImmutable.string(p.routine) +
      ContainsImmutable.digest(p.digest);

  factory ContainsImmutable.digestProof(Proof_Digest p) =>
      ContainsImmutable.txBind(p.transactionBind) + ContainsImmutable.preimage(p.preimage);

  factory ContainsImmutable.signature(Proposition_DigitalSignature p) =>
      ContainsImmutable.string(Tokens.digitalSignature) +
      ContainsImmutable.string(p.routine) +
      ContainsImmutable.verificationKey(p.verificationKey);

  factory ContainsImmutable.signatureProof(Proof_DigitalSignature p) =>
      ContainsImmutable.txBind(p.transactionBind) + ContainsImmutable.witness(p.witness);

  factory ContainsImmutable.heightRange(Proposition_HeightRange p) =>
      ContainsImmutable.string(Tokens.heightRange) +
      ContainsImmutable.string(p.chain) +
      ContainsImmutable.int64(p.min) +
      ContainsImmutable.int64(p.max);

  factory ContainsImmutable.heightRangeProof(Proof_HeightRange p) => ContainsImmutable.txBind(p.transactionBind);

  factory ContainsImmutable.tickRange(Proposition_TickRange p) =>
      ContainsImmutable.string(Tokens.tickRange) + ContainsImmutable.int64(p.min) + ContainsImmutable.int64(p.max);

  factory ContainsImmutable.tickRangeProof(Proof_TickRange p) => ContainsImmutable.txBind(p.transactionBind);

  factory ContainsImmutable.exactMatch(Proposition_ExactMatch p) =>
      ContainsImmutable.string(Tokens.exactMatch) + ContainsImmutable.string(p.location) + p.compareTo.immutable;

  factory ContainsImmutable.exactMatchProof(Proof_ExactMatch p) => ContainsImmutable.txBind(p.transactionBind);

  factory ContainsImmutable.lessThan(Proposition_LessThan p) =>
      ContainsImmutable.string(Tokens.lessThan) +
      ContainsImmutable.string(p.location) +
      ContainsImmutable.int128(p.compareTo);

  factory ContainsImmutable.lessThanProof(Proof_LessThan p) => ContainsImmutable.txBind(p.transactionBind);

  factory ContainsImmutable.greaterThan(Proposition_GreaterThan p) =>
      ContainsImmutable.string(Tokens.greaterThan) +
      ContainsImmutable.string(p.location) +
      ContainsImmutable.int128(p.compareTo);

  factory ContainsImmutable.greaterThanProof(Proof_GreaterThan p) => ContainsImmutable.txBind(p.transactionBind);

  factory ContainsImmutable.equalTo(Proposition_EqualTo p) =>
      ContainsImmutable.string(Tokens.equalTo) +
      ContainsImmutable.string(p.location) +
      ContainsImmutable.int128(p.compareTo);

  factory ContainsImmutable.equalToProof(Proof_EqualTo p) => ContainsImmutable.txBind(p.transactionBind);

  factory ContainsImmutable.threshold(Proposition_Threshold p) =>
      ContainsImmutable.string(Tokens.threshold) +
      ContainsImmutable.int(p.threshold) +
      ContainsImmutable.list(p.challenges);

  factory ContainsImmutable.thresholdProof(Proof_Threshold p) =>
      ContainsImmutable.txBind(p.transactionBind) + ContainsImmutable.list(p.responses);

  factory ContainsImmutable.not(Proposition_Not p) =>
      ContainsImmutable.string(Tokens.not) + ContainsImmutable.proposition(p.proposition);

  factory ContainsImmutable.notProof(Proof_Not p) =>
      ContainsImmutable.txBind(p.transactionBind) + ContainsImmutable.proof(p.proof);

  factory ContainsImmutable.and(Proposition_And p) =>
      ContainsImmutable.string(Tokens.and) +
      ContainsImmutable.proposition(p.left) +
      ContainsImmutable.proposition(p.right);

  factory ContainsImmutable.andProof(Proof_And p) =>
      ContainsImmutable.txBind(p.transactionBind) + ContainsImmutable.proof(p.left) + ContainsImmutable.proof(p.right);

  factory ContainsImmutable.or(Proposition_Or p) =>
      ContainsImmutable.string(Tokens.or) +
      ContainsImmutable.proposition(p.left) +
      ContainsImmutable.proposition(p.right);

  factory ContainsImmutable.orProof(Proof_Or p) =>
      ContainsImmutable.txBind(p.transactionBind) + ContainsImmutable.proof(p.left) + ContainsImmutable.proof(p.right);

  factory ContainsImmutable.proposition(Proposition p) {
    if (p.hasLocked()) {
      return ContainsImmutable.locked(p.locked);
    } else if (p.hasDigest()) {
      return ContainsImmutable.digestProposition(p.digest);
    } else if (p.hasDigitalSignature()) {
      return ContainsImmutable.signature(p.digitalSignature);
    } else if (p.hasHeightRange()) {
      return ContainsImmutable.heightRange(p.heightRange);
    } else if (p.hasTickRange()) {
      return ContainsImmutable.tickRange(p.tickRange);
    } else if (p.hasExactMatch()) {
      return ContainsImmutable.exactMatch(p.exactMatch);
    } else if (p.hasLessThan()) {
      return ContainsImmutable.lessThan(p.lessThan);
    } else if (p.hasGreaterThan()) {
      return ContainsImmutable.greaterThan(p.greaterThan);
    } else if (p.hasEqualTo()) {
      return ContainsImmutable.equalTo(p.equalTo);
    } else if (p.hasThreshold()) {
      return ContainsImmutable.threshold(p.threshold);
    } else if (p.hasNot()) {
      return ContainsImmutable.not(p.not);
    } else if (p.hasAnd()) {
      return ContainsImmutable.and(p.and);
    } else if (p.hasOr()) {
      return ContainsImmutable.or(p.or);
    } else {
      throw Exception('Invalid Proposition type ${p.runtimeType}');
    }
  }

  factory ContainsImmutable.proof(Proof p) {
    print(p.whichValue());
    print(p.hasLocked());
    print(p.hasDigest());
    print(p.hasDigitalSignature());
    print(p.hasHeightRange());

    print(p.hasTickRange());
    print(p.hasExactMatch());
    print(p.hasLessThan());

    print(p.hasGreaterThan());
    print(p.hasEqualTo());
    print(p.hasThreshold());

    print(p.hasNot());
    print(p.hasAnd());
    print(p.hasOr());


    if (p.hasLocked()) {
      return ContainsImmutable.lockedProof(p.locked);
    } else if (p.hasDigest()) {
      return ContainsImmutable.digestProof(p.digest);
    } else if (p.hasDigitalSignature()) {
      return ContainsImmutable.signatureProof(p.digitalSignature);
    } else if (p.hasHeightRange()) {
      return ContainsImmutable.heightRangeProof(p.heightRange);
    } else if (p.hasTickRange()) {
      return ContainsImmutable.tickRangeProof(p.tickRange);
    } else if (p.hasExactMatch()) {
      return ContainsImmutable.exactMatchProof(p.exactMatch);
    } else if (p.hasLessThan()) {
      return ContainsImmutable.lessThanProof(p.lessThan);
    } else if (p.hasGreaterThan()) {
      return ContainsImmutable.greaterThanProof(p.greaterThan);
    } else if (p.hasEqualTo()) {
      return ContainsImmutable.equalToProof(p.equalTo);
    } else if (p.hasThreshold()) {
      return ContainsImmutable.thresholdProof(p.threshold);
    } else if (p.hasNot()) {
      return ContainsImmutable.notProof(p.not);
    } else if (p.hasAnd()) {
      return ContainsImmutable.andProof(p.and);
    } else if (p.hasOr()) {
      return ContainsImmutable.orProof(p.or);
    } else {
      throw Exception('Invalid Proof type ${p.runtimeType}');
    }
  }

  /// dynamically handles processing for generic object
  /// consider using the direct type for better performance
  ///
  /// primarily implemented for the List function
  static ContainsImmutable apply(type) {
    /// dart does not support proper type checking in switch statements
    /// ergo: A horrible if/else chain
    if (type is ContainsImmutable) {
      return type;
    } else if (type is ImmutableBytes) {
      return ContainsImmutable(type);
    }

    /// base types
    else if (type is Uint8List || type is List<int>) {
      return ContainsImmutable(type);
    } else if (type is int) {
      return ContainsImmutable.int(type);
    } else if (type is String) {
      return ContainsImmutable.string(type);
    } else if (type is Int64) {
      return ContainsImmutable.int64(type);
    } else if (type is Int128) {
      return ContainsImmutable.int128(type);
    } else if (type is Option<ContainsImmutable>) {
      return ContainsImmutable.option(type);
    } else if (type is SmallData) {
      return ContainsImmutable.small(type);
    } else if (type is Root) {
      return ContainsImmutable.root(type);
    } else if (type is ByteString) {
      return ContainsImmutable.byteString(type);
    } else if (type is str.Struct) {
      return ContainsImmutable.struct(type);
    } else if (type is List) {
      return ContainsImmutable.list(type);
    }

    /// pb types
    /// Verification keys
    else if (type is VerificationKey) {
      return ContainsImmutable.verificationKey(type);
    } else if (type is VerificationKey_Ed25519Vk) {
      return ContainsImmutable.ed25519VerificationKey(type);
    } else if (type is VerificationKey_ExtendedEd25519Vk) {
      return ContainsImmutable.extendedEd25519VerificationKey(type);
    }

    /// Datum Types
    else if (type is Witness) {
      return ContainsImmutable.witness(type);
    } else if (type is Datum) {
      return ContainsImmutable.datum(type);
    } else if (type is Datum_Eon) {
      return ContainsImmutable.eonDatum(type);
    } else if (type is Datum_Era) {
      return ContainsImmutable.eraDatum(type);
    } else if (type is Datum_Epoch) {
      return ContainsImmutable.epochDatum(type);
    } else if (type is Datum_Header) {
      return ContainsImmutable.headerDatum(type);
    } else if (type is Datum_IoTransaction) {
      return ContainsImmutable.ioTransactionDatum(type);
    } else if (type is Datum_GroupPolicy) {
      return ContainsImmutable.groupPolicyDatum(type);
    } else if (type is Datum_SeriesPolicy) {
      return ContainsImmutable.seriesPolicyDatum(type);
    }

    /// Io Transactions
    else if (type is IoTransaction) {
      return ContainsImmutable.ioTransaction(type);
    } else if (type is Schedule) {
      return ContainsImmutable.iotxSchedule(type);
    } else if (type is SpentTransactionOutput) {
      return ContainsImmutable.spentOutput(type);
    } else if (type is UnspentTransactionOutput) {
      return ContainsImmutable.unspentOutput(type);
    } else if (type is Box) {
      return ContainsImmutable.box(type);
    }

    /// levels
    else if (type is Value) {
      return ContainsImmutable.value(type);
    } else if (type is Value_LVL) {
      return ContainsImmutable.lvlValue(type);
    } else if (type is Value_TOPL) {
      return ContainsImmutable.toplValue(type);
    } else if (type is Value_Asset) {
      return ContainsImmutable.assetValue(type);
    } else if (type is Value_Series) {
      return ContainsImmutable.seriesValue(type);
    } else if (type is Value_Group) {
      return ContainsImmutable.groupValue(type);
    }

    // extra
    else if (type is Evidence) {
      return ContainsImmutable.evidence(type);
    } else if (type is Digest) {
      return ContainsImmutable.digest(type);
    } else if (type is Preimage) {
      return ContainsImmutable.preimage(type);
    } else if (type is AccumulatorRootId) {
      return ContainsImmutable.accumulatorRoot32Identifier(type);
    } else if (type is LockId) {
      return ContainsImmutable.boxLock32Identifier(type);
    } else if (type is TransactionId) {
      return ContainsImmutable.transactionIdentifier(type);
    } else if (type is GroupId) {
      return ContainsImmutable.groupIdentifier(type);
    } else if (type is SeriesId) {
      return ContainsImmutable.seriesIdValue(type);
    } else if (type is TransactionOutputAddress) {
      return ContainsImmutable.transactionOutputAddress(type);
    } else if (type is LockAddress) {
      return ContainsImmutable.lockAddress(type);
    } else if (type is StakingAddress) {
      return ContainsImmutable.stakingAddress(type);
    } else if (type is FungibilityType) {
      return ContainsImmutable.fungibility(type);
    } else if (type is QuantityDescriptorType) {
      return ContainsImmutable.quantityDescriptor(type);
    }

    /// signatures
    else if (type is SignatureKesSum) {
      return ContainsImmutable.signatureKesSum(type);
    } else if (type is SignatureKesProduct) {
      return ContainsImmutable.signatureKesProduct(type);
    } else if (type is StakingRegistration) {
      return ContainsImmutable.stakingRegistration(type);
    } else if (type is Lock_Predicate) {
      return ContainsImmutable.predicateLock(type);
    } else if (type is Lock_Image) {
      return ContainsImmutable.imageLock(type);
    } else if (type is Lock_Commitment) {
      return ContainsImmutable.commitmentLock(type);
    } else if (type is Lock) {
      return ContainsImmutable.lock(type);
    } else if (type is Attestation_Predicate) {
      return ContainsImmutable.predicateAttestation(type);
    } else if (type is Attestation_Image) {
      return ContainsImmutable.imageAttestation(type);
    } else if (type is Attestation_Commitment) {
      return ContainsImmutable.commitmentAttestation(type);
    } else if (type is Attestation) {
      return ContainsImmutable.attestation(type);
    } else if (type is TransactionInputAddress) {
      return ContainsImmutable.transactionInputAddressContains(type);
    } else if (type is Challenge_PreviousProposition) {
      return ContainsImmutable.previousPropositionChallengeContains(type);
    } else if (type is Challenge) {
      return ContainsImmutable.challengeContains(type);
    }

    /// events
    else if (type is Event_Eon) {
      return ContainsImmutable.eonEvent(type);
    } else if (type is Event_Era) {
      return ContainsImmutable.eraEvent(type);
    } else if (type is Event_Epoch) {
      return ContainsImmutable.epochEvent(type);
    } else if (type is Event_Header) {
      return ContainsImmutable.headerEvent(type);
    } else if (type is Event_IoTransaction) {
      return ContainsImmutable.iotxEventImmutable(type);
    } else if (type is Event) {
      return ContainsImmutable.eventImmutable(type);
    } else if (type is TxBind) {
      return ContainsImmutable.txBind(type);
    }

    /// Propositions and Proofs
    else if (type is Proposition_Locked) {
      return ContainsImmutable.locked(type);
    } else if (type is Proof_Locked) {
      return ContainsImmutable.lockedProof(type);
    } else if (type is Proposition_Digest) {
      return ContainsImmutable.digestProposition(type);
    } else if (type is Proof_Digest) {
      return ContainsImmutable.digestProof(type);
    } else if (type is Proposition_DigitalSignature) {
      return ContainsImmutable.signature(type);
    } else if (type is Proof_DigitalSignature) {
      return ContainsImmutable.signatureProof(type);
    } else if (type is Proposition_HeightRange) {
      return ContainsImmutable.heightRange(type);
    } else if (type is Proof_HeightRange) {
      return ContainsImmutable.heightRangeProof(type);
    } else if (type is Proposition_TickRange) {
      return ContainsImmutable.tickRange(type);
    } else if (type is Proof_TickRange) {
      return ContainsImmutable.tickRangeProof(type);
    } else if (type is Proposition_ExactMatch) {
      return ContainsImmutable.exactMatch(type);
    } else if (type is Proof_ExactMatch) {
      return ContainsImmutable.exactMatchProof(type);
    } else if (type is Proposition_LessThan) {
      return ContainsImmutable.lessThan(type);
    } else if (type is Proof_LessThan) {
      return ContainsImmutable.lessThanProof(type);
    } else if (type is Proposition_GreaterThan) {
      return ContainsImmutable.greaterThan(type);
    } else if (type is Proof_GreaterThan) {
      return ContainsImmutable.greaterThanProof(type);
    } else if (type is Proposition_EqualTo) {
      return ContainsImmutable.equalTo(type);
    } else if (type is Proof_EqualTo) {
      return ContainsImmutable.equalToProof(type);
    } else if (type is Proposition_Threshold) {
      return ContainsImmutable.threshold(type);
    } else if (type is Proof_Threshold) {
      return ContainsImmutable.thresholdProof(type);
    } else if (type is Proposition_Not) {
      return ContainsImmutable.not(type);
    } else if (type is Proof_Not) {
      return ContainsImmutable.notProof(type);
    } else if (type is Proposition_And) {
      return ContainsImmutable.and(type);
    } else if (type is Proof_And) {
      return ContainsImmutable.andProof(type);
    } else if (type is Proposition_Or) {
      return ContainsImmutable.or(type);
    } else if (type is Proof_Or) {
      return ContainsImmutable.orProof(type);
    } else if (type is Proposition) {
      return ContainsImmutable.proposition(type);
    } else if (type is Proof) {
      return ContainsImmutable.proof(type);
    } else {
      throw Exception('Invalid type ${type.runtimeType}');
    }
  }
}

extension ImmutableByteExtensions on ImmutableBytes {
  ImmutableBytes operator +(ImmutableBytes other) => ImmutableBytes(value: value + other.value);
}

extension ContainsImmutableExtensions on ContainsImmutable {
  ContainsImmutable operator +(ContainsImmutable other) => ContainsImmutable(immutableBytes + other.immutableBytes);
}

extension ImmutableByteUint8ListExtensions on Uint8List {
  /// Creates an ImmutableBytes object from a [Uint8List]
  ImmutableBytes get immutableBytes => ImmutableBytes(value: this);

  /// Creates an ContainsImmutable object from a [Uint8List]
  ContainsImmutable get immutable => ContainsImmutable(immutableBytes);
}

extension ImmutableByteIntListExtensions on List<int> {
  /// Creates an ImmutableBytes object from a [int] list
  ImmutableBytes get immutableBytes => ImmutableBytes(value: this);

  /// Creates an ContainsImmutable object from a [int] list
  ContainsImmutable get immutable => ContainsImmutable(immutableBytes);
}

extension IoTransactionContainsImmutableExtensions on IoTransaction {
  ImmutableBytes get immutable => ContainsImmutable.ioTransaction(this).immutableBytes;
}
