import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/model/box/token_value_holder.dart';

part 'recipient.g.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class Recipient {
  final String key;
  final AssetValue value;

  Recipient(this.key, this.value);

  /// A necessary factory constructor for creating a new Recipient instance
  /// from a map. Pass the map to the generated `_$RecipientFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Recipient.
  factory Recipient.fromJson(Map<String, dynamic> json) =>
      _$RecipientFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$RecipientToJson`.
  List toJson() => [key, value.toJson()];
}
