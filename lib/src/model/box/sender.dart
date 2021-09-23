import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/model/box/box.dart';

class Sender {
  final ToplAddress senderAddress;
  final Nonce nonce;

  Sender(this.senderAddress, this.nonce);

  /// A necessary factory constructor for creating a new Sender instance
  /// from a map. Pass the map to the generated `_$SenderFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Sender.
  factory Sender.fromJson(List<dynamic> jsonList) => Sender(
      ToplAddress.fromBase58(jsonList[0] as String),
      int.parse(jsonList[1] as String));

  String toJson() => toString();

  @override
  int get hashCode => senderAddress.hashCode ^ nonce.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Sender &&
      other.senderAddress == senderAddress &&
      other.nonce == nonce;

  @override
  String toString() => 'Address: ${senderAddress.toBase58()}, Nonce: $nonce';
}
