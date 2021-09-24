import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:mubrambl/src/utils/codecs/string_data_types_codec.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';
import 'package:pinenacl/api.dart';

part 'evidence.g.dart';

/// Evidence content serves as a fingerprint (or commitment) of a particular proposition that is used to lock a box. Boxes
/// are locked with 'Evidence' which is the concatentation of a typePrefix ++ content. The type prefix denotes what type
/// of proposition the content references and the content serves as the commitment that a proposition will be checked
/// against when a box is being unlocked during a transaction.
///
/// @param evBytes an array of bytes of length 'contentLength' (currently 32 bytes) generated from a proposition
///
typedef EvidenceTypePrefix = int;

@JsonSerializable(checked: true, explicitToJson: true)
class Evidence {
  static const contentLength = 32;

  final EvidenceTypePrefix prefix;
  final int size = 1 + contentLength; //length of typePrefix + contentLength
  final Digest evBytes;

  Evidence(this.prefix, this.evBytes);

  /// A necessary factory constructor for creating a new Evidence instance
  /// from a map. Pass the map to the generated `_$EvidenceFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Evidence.
  factory Evidence.fromJson(Map<String, dynamic> json) =>
      _$EvidenceFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$EvidenceToJson`.
  Map<String, dynamic> toJson() => _$EvidenceToJson(this);

  factory Evidence.apply(EvidenceTypePrefix prefix, Digest content) {
    assert(content.bytes.length == contentLength,
        'Invalid evidence: incorrect EvidenceContent length');
    return Evidence(prefix, content);
  }

  factory Evidence.fromBase58(String evidence) {
    final decodedEvidence = Base58Data.validated(evidence).value;
    return Evidence.apply(decodedEvidence[0],
        Digest.from(decodedEvidence.sublist(1), Evidence.contentLength));
  }

  @override
  String toString() {
    return Uint8List.fromList([prefix] + evBytes.bytes).encodeAsBase58().show;
  }

  @override
  bool operator ==(Object other) =>
      other is Evidence && evBytes == other.evBytes;

  @override
  int get hashCode => evBytes.hashCode;
}
