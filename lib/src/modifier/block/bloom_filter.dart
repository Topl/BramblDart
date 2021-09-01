import 'dart:convert';
import 'dart:typed_data';

import 'package:bip_topl/bip_topl.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';

final _size = BLOOM_FILTER_BYTES * 8;
final _numLongs = _size ~/ 64;

@JsonSerializable(checked: true, explicitToJson: true)
class BloomFilter {
  final Uint8List value;
  BloomFilter(this.value);

  factory BloomFilter.empty() {
    return BloomFilter(Uint8List(_numLongs));
  }

  factory BloomFilter.newFilter(Uint8List value) {
    assert(value.length == _numLongs,
        'Invalid Bloom Filter Length: ${value.length}. Bloom filters must be a List of length $_numLongs');
    return BloomFilter(value);
  }

  ///
  /// Recreate a bloom filter from a string encoding
  factory BloomFilter.fromBase58(Base58Data data) {
    return BloomFilter(data.value);
  }

  /// A necessary factory constructor for creating a new BloomFilter instance
  /// from a map.
  factory BloomFilter.fromJson(Map<String, dynamic> json) =>
      BloomFilter.fromBase58(json['bloomFilter']);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON.
  Map<String, dynamic> toJson() => json.decode(toString());

  @override
  String toString() => Base58Encoder.instance.encode(value);

  /// TODO: Write the contains method that takes in a bloomTopic and returns whether or not the topic is in the filter
  bool contains(Uint8List bloomTopic) {
    throw UnsupportedError('Not yet implemented');
  }

  @override
  bool operator ==(Object other) =>
      other is BloomFilter && ListEquality().equals(value, other.value);

  @override
  int get hashCode => value.hashCode;
}
