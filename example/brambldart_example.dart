import 'package:brambldart/brambldart.dart';
import 'package:brambldart/src/crypto/hash/hash.dart';
import 'package:brambldart/src/utils/extensions.dart';

void main() {
  /// encode String to blake2b256
  const input = "Foobar";

  Blake2b256().hash(input.toUtf8Uint8List());
}
