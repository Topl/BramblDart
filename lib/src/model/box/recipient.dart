part of 'package:mubrambl/model.dart';

class AssetRecipient {
  final ToplAddress key;
  final AssetValue value;

  AssetRecipient(this.key, this.value);

  /// A necessary factory constructor for creating a new Recipient instance
  /// from a map. Pass the map to the generated `_$RecipientFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Recipient.
  factory AssetRecipient.fromJson(List jsonList) => AssetRecipient(
      ToplAddress.fromBase58(jsonList[0] as String),
      AssetValue.fromJson(jsonList[1] as Map<String, dynamic>));

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$RecipientToJson`.
  List toJson() => [key.toBase58(), value.toJson()];

  @override
  int get hashCode => key.hashCode ^ value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is AssetRecipient && other.key == key && other.value == value;
}

class SimpleRecipient {
  final ToplAddress key;
  final SimpleValue value;

  SimpleRecipient(this.key, this.value);

  /// A necessary factory constructor for creating a new Recipient instance
  /// from a map. Pass the map to the generated `_$RecipientFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Recipient.
  factory SimpleRecipient.fromJson(List jsonList) => SimpleRecipient(
      ToplAddress.fromBase58(jsonList[0] as String),
      SimpleValue.fromJson(jsonList[1] as Map<String, dynamic>));

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$RecipientToJson`.
  List toJson() => [key.toBase58(), value.quantity.toString()];

  /// This second json encoder is to support the broadcastTx representation of this recipient.
  List toBroadcastJson() => [key.toBase58(), value.toJson()];
}
