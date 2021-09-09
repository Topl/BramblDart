import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/attestation/evidence.dart';
import 'package:mubrambl/src/model/box/box_id.dart';
import 'package:mubrambl/src/model/box/generic_box.dart';
import 'package:mubrambl/src/model/box/token_value_holder.dart';

part 'box.g.dart';

typedef Nonce = int;
typedef BoxType = int;

@JsonSerializable(checked: true, explicitToJson: true)
class Box<T> extends GenericBox {
  @override
  final Evidence evidence;
  @override
  @_Converter()
  final T value;
  final Nonce nonce;
  final String typeString;
  @override
  @BoxIdConverter()
  late BoxId boxId = BoxId.apply(this);

  Box(this.evidence, this.nonce, this.typeString, this.value)
      : super(evidence, value);

  @override
  int get hashCode => nonce;

  @override
  String toString() {
    return typeString + json.encode(toJson());
  }

  @override
  bool operator ==(Object other) => other is Box && nonce == other.nonce;

  /// A necessary factory constructor for creating a new Box instance
  /// from a map. Pass the map to the generated `_$BoxFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Box.
  factory Box.fromJson(Map<String, dynamic> json) => _$BoxFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$BoxToJson`.
  Map<String, dynamic> toJson() => _$BoxToJson(this);
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
    return T as Object;
  }
}

abstract class TokenBox extends Box {
  final TokenValueHolder tokenValueHolder;

  @override
  final Evidence evidence;

  @override
  final Nonce nonce;

  TokenBox(
      this.evidence, this.nonce, this.tokenValueHolder, typeString, boxType)
      : super(evidence, nonce, typeString, tokenValueHolder);
}
