import 'dart:convert';
import 'dart:typed_data';

extension StringOps on String {
  // return the byte array of a string after ensuring valid encoding
  Uint8List? _getValidBytes(String inString, Encoding encoding) {
    if (utf8.decode(encoding.encode(inString), allowMalformed: true) ==
        inString) {
      return Uint8List.fromList(encoding.encode(inString));
    }
  }

  // returns the byte array of a string after ensuring latin-1 encoding
  Uint8List? getValidLatinBytes() => _getValidBytes(this, latin1);
}
