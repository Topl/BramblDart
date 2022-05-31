part of 'package:brambldart/model.dart';

const _size = bloomFilterBytes * 8;
const _numLongs = _size ~/ 64;

@JsonSerializable(checked: true, explicitToJson: true)
class BloomFilter {
  @Uint8ListConverter()
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
  /// from a map. Pass the map to the generated `_$BloomFilterFromJson()` constructor.
  /// The constructor is named after the source class, in this case, BloomFilter.
  factory BloomFilter.fromJson(Map<String, dynamic> json) =>
      _$BloomFilterFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$BloomFilterToJson`.
  Map<String, dynamic> toJson() => _$BloomFilterToJson(this);

  @override
  String toString() => Base58Encoder.instance.encode(value);

  bool contains(Uint8List bloomTopic) {
    throw UnsupportedError('Not yet implemented');
  }

  @override
  bool operator ==(Object other) =>
      other is BloomFilter && const ListEquality().equals(value, other.value);

  @override
  int get hashCode => value.hashCode;
}
