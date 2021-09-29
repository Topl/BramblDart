// ignore_for_file: overridden_fields

import 'package:json_annotation/json_annotation.dart';

import 'package:mubrambl/src/attestation/evidence.dart';
import 'package:mubrambl/src/model/box/box_id.dart';
import 'package:mubrambl/src/model/box/generic_box.dart';
import 'package:mubrambl/src/model/box/token_value_holder.dart';

part 'box.g.dart';

typedef Nonce = String;
typedef BoxType = int;

@JsonSerializable(checked: true, explicitToJson: true)
class Box<T> extends GenericBox {
  @override
  final Evidence evidence;
  @override
  @_Converter()
  final T value;
  final Nonce nonce;
  final String type;
  @override
  @BoxIdConverter()
  @JsonKey(name: 'id')
  late BoxId boxId = BoxId.apply(this);

  Box(
    this.evidence,
    this.value,
    this.nonce,
    this.type,
  ) : super(evidence, value);

  @override
  int get hashCode {
    return evidence.hashCode ^ value.hashCode ^ nonce.hashCode ^ type.hashCode;
  }

  @override
  String toString() {
    return 'Box(evidence: $evidence, value: $value, nonce: $nonce, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Box<T> &&
        other.evidence == evidence &&
        other.value == value &&
        other.nonce == nonce &&
        other.type == type;
  }

  /// A necessary factory constructor for creating a new Box instance
  /// from a map. Pass the map to the generated `_$BoxFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Box.
  factory Box.fromJson(Map<String, dynamic> json) => _$BoxFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$BoxToJson`.
  Map<String, dynamic> toJson() => _$BoxToJson(this);

  Box<T> copyWith({
    Evidence? evidence,
    T? value,
    Nonce? nonce,
    String? type,
  }) {
    return Box<T>(
      evidence ?? this.evidence,
      value ?? this.value,
      nonce ?? this.nonce,
      type ?? this.type,
    );
  }
}

class _Converter<T> implements JsonConverter<T, Object> {
  const _Converter();

  @override
  T fromJson(Object json) {
    if (json is Map<String, dynamic> &&
        json.containsKey('type') &&
        json['type'] == 'Simple') {
      return SimpleValue.fromJson(json) as T;
    }
    if (json is Map<String, dynamic> &&
        json.containsKey('type') &&
        json['type'] == 'Asset') {
      return AssetValue.fromJson(json) as T;
    }
    // This will only work if `json` is a native JSON type:
    //   num, String, bool, null, etc
    // *and* is assignable to `T`.
    return json as T;
  }

  @override
  Object toJson(T object) {
    // This will only work if `object` is a native JSON type:
    //   num, String, bool, null, etc
    // Or if it has a `toJson()` function`.
    // ignore: unnecessary_cast
    return T as Object;
  }
}

@JsonSerializable(checked: true, explicitToJson: true)
class TokenBox extends Box {
  @override
  final TokenValueHolder value;

  @override
  final Nonce nonce;

  TokenBox(
    this.value,
    Evidence evidence,
    this.nonce,
    String type,
  ) : super(evidence, value, nonce, type);

  @override
  String toString() =>
      'TokenBox(tokenValueHolder: $value, evidence: $evidence, nonce: $nonce)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TokenBox &&
        other.value == value &&
        other.evidence == evidence &&
        other.nonce == nonce;
  }

  @override
  int get hashCode => value.hashCode ^ evidence.hashCode ^ nonce.hashCode;

  /// A necessary factory constructor for creating a new TokenBox instance
  /// from a map. Pass the map to the generated `_$TokenBoxFromJson()` constructor.
  /// The constructor is named after the source class, in this case, TokenBox.
  factory TokenBox.fromJson(Map<String, dynamic> json) =>
      _$TokenBoxFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TokenBoxToJson`.
  @override
  Map<String, dynamic> toJson() => _$TokenBoxToJson(this);
}
