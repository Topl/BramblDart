import 'dart:convert';
import 'dart:typed_data';

import 'extensions.dart';

class Json {
  static Uint8List decodeUint8List(String encoded) {
    final dynamicDecode = jsonDecode(encoded) as List<dynamic>;
    final decoded = dynamicDecode.map((i) => i as int).toList();
    return Uint8List.fromList(decoded);
  }

  static String encodeUint8List(Uint8List data) {
    final toEncode = data.toIntList();
    return jsonEncode(toEncode);
  }
}
