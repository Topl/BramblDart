import 'dart:typed_data';

final hexRegex = RegExp('^(0x)?[0-9a-fA-F]{1,}\$');

String toHex(Uint8List bArr) {
  var length = bArr.length;
  if (length <= 0) {
    return '';
  }
  var cArr = Uint8List(length << 1);
  var i = 0;
  for (var i2 = 0; i2 < length; i2++) {
    var i3 = i + 1;
    var cArr2 = [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'a',
      'b',
      'c',
      'd',
      'e',
      'f'
    ];

    var index = (bArr[i2] >> 4) & 15;
    cArr[i] = cArr2[index].codeUnitAt(0);
    i = i3 + 1;
    cArr[i3] = cArr2[bArr[i2] & 15].codeUnitAt(0);
  }
  return String.fromCharCodes(cArr);
}

bool isValidHex(String hex) {
  return hexRegex.hasMatch(hex);
}
