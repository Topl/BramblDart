import 'package:brambldart/brambldart.dart';
import 'package:test/test.dart';

void main() {
  group('EncodingSpec', () {
    final encoding = Encoding();

    test('Main Network Main Ledger Zero Test', () {
      final zeroes = List.filled(64, '0').join();
      final input = encoding.decodeFromHex('8A11054CE7B07A00$zeroes').get();
      expect(
        encoding.encodeToBase58Check(input),
        'mtetmain1y1Rqvj9PiHrsoF4VRHKscLPArgdWe44ogoiKoxwfevERNVgxLLh',
      );
    });

    test('Valhalla Network Main Ledger Zero Test', () {
      expect(
        encoding.encodeToBase58Check(
          encoding.decodeFromHex('A5BF4108E7B07A00${List.filled(64, '0').join()}').get(),
        ),
        'vtetDGydU3EhwSbcRVFiuHmyP37Y57BwpmmutR7ZPYdD8BYssHEj3FRhr2Y8',
      );
    });

    test('Private Network Main Ledger Zero Test', () {
      expect(
        encoding.encodeToBase58Check(
          encoding.decodeFromHex('934B1900E7B07A00${List.filled(64, '0').join()}').get(),
        ),
        'ptetP7jshHTuV9bmPmtVLm6PtUzBMZ8iYRvAxvbGTJ5VgiEPHqCCnZ8MLLdi',
      );
    });

    test('Main Network Main Ledger All One Test', () {
      expect(
        encoding.encodeToBase58Check(
          encoding.decodeFromHex('8A11054CE7B07A00${List.filled(64, 'F').join()}').get(),
        ),
        'mtetmain1y3Nb6xbRZiY6w4eCKrwsZeywmoFEHkugUSnS47dZeaEos36pZwb',
      );
    });

    test('Valhalla Network Main Ledger All One Test', () {
      expect(
        encoding.encodeToBase58Check(
          encoding.decodeFromHex('A5BF4108E7B07A00${List.filled(64, 'F').join()}').get(),
        ),
        'vtetDGydU3Gegcq4TLgQ8RbZ5whA54WYbgtXc4pQGLGHERhZmGtjRjwruMj7',
      );
    });

    test('Private Network Main Ledger All One Test', () {
      expect(
        encoding.encodeToBase58Check(
          encoding.decodeFromHex('934B1900E7B07A00${List.filled(64, 'F').join()}').get(),
        ),
        'ptetP7jshHVrEKqDRdKAZtuybPZoMWTKKM2ngaJ7L5iZnxP5BprDB3hGJEFr',
      );
    });

    test('Encode decode', () {
      expect(
        String.fromCharCodes(
          encoding.decodeFromBase58(encoding.encodeToBase58('Hello World!'.toCodeUnitUint8List())).get(),
        ),
        'Hello World!',
      );
    });
  });
}
