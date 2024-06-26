// ignore_for_file: unnecessary_new

import 'dart:typed_data';

import 'package:brambldart/brambldart.dart';
import 'package:brambldart/src/utils/extensions.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

void main() {
  group('Aggregation Operation Tests', () {
    // test('typeIdentifier grouping', () {
    //   var testMap = mockValues.groupBy((value) => value.value.typeIdentifier);
    //   var expectedMap = {
    //     lvlValue.value.typeIdentifier: [lvlValue, lvlValue.copy()],
    //     groupValue.value.typeIdentifier: [groupValue, groupValue.copy()],
    //     groupValueAlt.value.typeIdentifier: [groupValueAlt],
    //     seriesValue.value.typeIdentifier: [seriesValue, seriesValue.copy()],
    //     seriesValueAlt.value.typeIdentifier: [seriesValueAlt],
    //     assetGroupSeries.value.typeIdentifier: [assetGroupSeries, assetGroupSeries.copy()],
    //     assetGroupSeriesAlt.value.typeIdentifier: [assetGroupSeriesAlt],
    //     assetGroup.value.typeIdentifier: [assetGroup, assetGroup.copy()],
    //     assetGroupAlt.value.typeIdentifier: [assetGroupAlt],
    //     assetSeries.value.typeIdentifier: [assetSeries, assetSeries.copy()],
    //     assetSeriesAlt.value.typeIdentifier: [assetSeriesAlt],
    //     assetGroupSeriesAccumulator.value.typeIdentifier: [
    //       assetGroupSeriesAccumulator,
    //       assetGroupSeriesAccumulator.copy()
    //     ],
    //     assetGroupSeriesAccumulatorAlt.value.typeIdentifier: [assetGroupSeriesAccumulatorAlt],
    //     assetGroupAccumulator.value.typeIdentifier: [assetGroupAccumulator, assetGroupAccumulator.copy()],
    //     assetGroupAccumulatorAlt.value.typeIdentifier: [assetGroupAccumulatorAlt],
    //     assetSeriesAccumulator.value.typeIdentifier: [assetSeriesAccumulator, assetSeriesAccumulator.copy()],
    //     assetSeriesAccumulatorAlt.value.typeIdentifier: [assetSeriesAccumulatorAlt],
    //     assetGroupSeriesFractionable.value.typeIdentifier: [
    //       assetGroupSeriesFractionable,
    //       assetGroupSeriesFractionable.copy()
    //     ],
    //     assetGroupSeriesFractionableAlt.value.typeIdentifier: [assetGroupSeriesFractionableAlt],
    //     assetGroupFractionable.value.typeIdentifier: [assetGroupFractionable, assetGroupFractionable.copy()],
    //     assetGroupFractionableAlt.value.typeIdentifier: [assetGroupFractionableAlt],
    //     assetSeriesFractionable.value.typeIdentifier: [assetSeriesFractionable, assetSeriesFractionable.copy()],
    //     assetSeriesFractionableAlt.value.typeIdentifier: [assetSeriesFractionableAlt],
    //     assetGroupSeriesImmutable.value.typeIdentifier: [assetGroupSeriesImmutable, assetGroupSeriesImmutable.copy()],
    //     assetGroupSeriesImmutableAlt.value.typeIdentifier: [assetGroupSeriesImmutableAlt],
    //     assetGroupImmutable.value.typeIdentifier: [assetGroupImmutable, assetGroupImmutable.copy()],
    //     assetGroupImmutableAlt.value.typeIdentifier: [assetGroupImmutableAlt],
    //     assetSeriesImmutable.value.typeIdentifier: [assetSeriesImmutable, assetSeriesImmutable.copy()],
    //     assetSeriesImmutableAlt.value.typeIdentifier: [assetSeriesImmutableAlt],
    //     toplValue.value.typeIdentifier: [toplValue, toplValue.copy()],
    //     toplReg1.value.typeIdentifier: [toplReg1],
    //     toplReg2.value.typeIdentifier: [toplReg2],
    //   };
    //   expect(testMap, equals(expectedMap));
    // });

    test('DefaultAggregationOps.aggregate > different types', () {
      final bytes = Uint8List.fromList([0, 195, 70]);

      // final signedBytes = Int8List.fromList(bytes);
      // print(signedBytes); // Prints: [0, -61, 70]

      final int decimalValue = ByteData.view(bytes.buffer).getInt16(0, Endian.little);
      // final int decimalValueAsSigned = ByteData.view(signedBytes.buffer).getInt16(0, Endian.little);
      // print(decimalValue); // Prints: -15616.
      // print(decimalValueAsSigned); // Prints: -15616.

      final bigIntValue = BigInt.from(decimalValue);
      print(bigIntValue);
      // print(bigIntValue.toUint8List()); // Prints: [195, 0]

      // final bigIntValueAsSigned = BigInt.from(decimalValueAsSigned);
      // print(bigIntValueAsSigned);
      // print(bigIntValueAsSigned.toUint8List());

      // final bytes2 = Uint8List.fromList([195, 70]);

      // final int decimalValue2 = ByteData.view(bytes2.buffer).getInt16(0, Endian.little);
      // print(decimalValue2); // Prints: 18115.

      // final bigIntValue2 = BigInt.from(decimalValue2);
      // print(bigIntValue2); // Prints: 18115.
      // print(bigIntValue2.toUint8List()); // Prints: [70, 195]

      // final bytes = Uint8List.fromList([0, 195, 70]);

      // convert to accurate bigInt
      final BigInt accurateBigIntValue = toAccurateBigInt(bytes);
      // convert to fast bigInt
      final BigInt fastBigIntValue = bytes.toBigInt;

      print(accurateBigIntValue);
      print(fastBigIntValue);

      // convert back into Uint8List (slow method)
      final Uint8List convertedBytes = fromAccurateBigIntWithOriginalBytes(accurateBigIntValue, bytes);
      print(convertedBytes);

      // convert back into Uint8List (Fast method)
      final Uint8List convertedBytes2 = convertedBytes.toUint8List();
      final Uint8List convertedBytes3 = fastBigIntValue.toUint8List();
      print(convertedBytes2);
    });
  });

  test("Speedtests vs Accuracy", () {
    measureExecutionTime('Original Implementation | supposedly Fast Method', () {
      final bytes = Uint8List.fromList([0, 195, 70]);
      final bigIntValue = bytes.toBigInt;
      print(bigIntValue);
      print(bigIntValue.toUint8List());
    });

    print("----------------------------------");

    measureExecutionTime("New Accurate Implementation From & To | Supposedly slower", () {
      final bytes = Uint8List.fromList([0, 195, 70]);
      final BigInt accurateBigIntValue = toAccurateBigInt(bytes);
      final Uint8List convertedBytes = fromAccurateBigIntWithOriginalBytes(accurateBigIntValue, bytes);
      print(accurateBigIntValue);
      print(convertedBytes);
    });

    print("----------------------------------");

    measureExecutionTime("New Mixed Implementation From & Old To | Supposedly slower", () {
      final bytes = Uint8List.fromList([0, 195, 70]);
      final BigInt accurateBigIntValue = toAccurateBigInt(bytes);
      // final Uint8List convertedBytes = fromAccurateBigInt(accurateBigIntValue, bytes);
      print(accurateBigIntValue);
      print(accurateBigIntValue.toUint8List());
    });

    print("----------------------------------");

    measureExecutionTime("New Mixed Implementation Old From & new To | Supposedly slower", () {
      final bytes = Uint8List.fromList([0, 195, 70]);
      final BigInt accurateBigIntValue = bytes.toBigInt;
      final Uint8List convertedBytes = fromAccurateBigIntWithOriginalBytes(accurateBigIntValue, bytes);
      print(accurateBigIntValue);
      print(convertedBytes);
    });
  });

  test('Int128 Math', () {
    final bigInt = BigInt.from(49990);
    final bigInt2 = BigInt.from(-15546);

    // print(bigIntToTwosComplement(bigInt));
    // print(bigIntToTwosComplement(bigInt2));

    // print(writeBigInt(bigInt));
    // print(writeBigInt(bigInt2));

    // print(bigInt.toByteData().buffer.asInt8List());
    // print(bigInt.toByteData().buffer.asUint8List());

    // print(bigInt2.toByteData().buffer.asInt8List());
    // print(bigInt2.toByteData().buffer.asUint8List());

    print(Int128(value: bigInt.toTwosComplement()));
    print(Int128(value: bigInt2.toTwosComplement()));

    // print(bigInt);
    // print(bigInt.toUint8List());
    // print(bigInt.toInt8List());
    // print(fromAccurateBigInt(bigInt));
    // print(bigInt.toInt128());
    // print(bigInt.toInt());
    // print(bigInt2.toInt());
    // print(bigIntToTwosComplement(bigInt));
    // print(bigIntToTwosComplement(bigInt2));

    // print(bigIntToUint8List(bigInt));
    // print(bigIntToUint8List(bigInt2));
    // print(bigIntToTwosComplement(bigInt));

    // Int128();
  });
}

BigInt toAccurateBigInt(Uint8List bytes) {
  final String hexString = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  return BigInt.parse(hexString, radix: 16);
}

Uint8List fromAccurateBigIntWithOriginalBytes(BigInt bigInt, Uint8List originalBytes) {
  final String hexString = bigInt.toRadixString(16).padLeft(originalBytes.length * 2, '0');
  final Uint8List bytes = Uint8List(hexString.length ~/ 2);
  for (int i = 0; i < hexString.length; i += 2) {
    final hex = hexString.substring(i, i + 2);
    bytes[i ~/ 2] = int.parse(hex, radix: 16);
  }
  return bytes;
}

Uint8List fromAccurateBigInt(BigInt bigInt) {
  final length = (bigInt.bitLength + 7) ~/ 8;
  final bytes = Uint8List(length);
  for (var i = 0; i < length; i++) {
    bytes[length - i - 1] = (bigInt >> (8 * i)).toInt() & 0xff;
  }
  if (bigInt.isNegative) {
    for (var i = 0; i < length; i++) {
      bytes[i] = ~bytes[i] & 0xff;
    }
    for (var i = length - 1; i >= 0; i--) {
      bytes[i]++;
      if (bytes[i] <= 0xff) {
        break;
      }
      bytes[i] = 0;
    }
  }
  return bytes;
}

Uint8List bigIntToUint8List(BigInt bigInt) {
  // Calculate the number of bytes needed to represent the BigInt
  final bytes = Uint8List((bigInt.bitLength + 7) ~/ 8 + 1);
  for (var i = 0; i < bytes.length; i++) {
    bytes[bytes.length - i - 1] = (bigInt >> (8 * i)).toInt() & 0xff;
  }
  if (bigInt.isNegative) {
    // Compute the two's complement for negative numbers
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = ~bytes[i] & 0xff;
    }
    for (var i = bytes.length - 1; i >= 0; i--) {
      bytes[i]++;
      if (bytes[i] <= 0xff) {
        break;
      }
      bytes[i] = 0;
    }
  }
  return bytes;
}

BigInt readBytes(Uint8List bytes) {
  BigInt result = BigInt.zero;

  for (final byte in bytes) {
    // reading in big-endian, so we essentially concat the new byte to the end
    result = (result << 8) | BigInt.from(byte & 0xff);
  }
  return result;
}

Uint8List writeBigInt(BigInt number) {
  // Not handling negative numbers. Decide how you want to do that.
  final int bytes = (number.bitLength + 7) >> 3;
  final b256 = BigInt.from(256);
  final result = Uint8List(bytes);
  for (int i = 0; i < bytes; i++) {
    result[bytes - 1 - i] = number.remainder(b256).toInt();
    number = number >> 8;
  }
  return result;
}

/// Converts a [Uint8List] byte buffer into a [BigInt]
BigInt _convertBytesToBigInt(Uint8List bytes) {
  BigInt result = BigInt.zero;

  for (final byte in bytes) {
    // reading in big-endian, so we essentially concat the new byte to the end
    result = (result << 8) | BigInt.from(byte);
  }
  return result;
}

void measureExecutionTime(String testName, Function functionToExecute) {
  final stopwatch = Stopwatch()..start();
  functionToExecute();
  stopwatch.stop();
  print('$testName executed in ${stopwatch.elapsed}');
}
