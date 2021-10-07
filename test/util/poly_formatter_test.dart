import 'package:brambldart/model.dart';
import 'package:brambldart/utils.dart';
import 'package:test/test.dart';

void main() {
  group('PolyFormatter - ', () {
    test('currency', () {
      final formatter = PolyFormatter.currency();
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120)));
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000)));
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000)));
      print(formatter.format(
          PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000)));
      expect(
          formatter.format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120)),
          equals('φ0.000000120'));
      expect(
          formatter
              .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000)),
          equals('φ0.000120000'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000)),
          equals('φ0.120000000'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000)),
          equals('φ120.000000000'));

      expect(
          () => formatter.format(PolyAmount.fromUnitAndValue(
              PolyUnit.nanopoly, 9000000000000000000)),
          throwsA(const TypeMatcher<ArgumentError>()));

      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 9007199254740991)),
          equals('φ9,007,199.254740991'));
    });
    test('compactCurrency', () {
      final formatter = PolyFormatter.compactCurrency();
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120)));
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000)));
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000)));
      print(formatter.format(
          PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000)));
      expect(
          formatter.format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120)),
          equals('φ0.000000120'));
      expect(
          formatter
              .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000)),
          equals('φ0.000120000'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000)),
          equals('φ0.120000000'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000)),
          equals('φ120'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000000)),
          equals('φ120K'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 9007199254740991)),
          equals('φ9.01M'));
      expect(
          () => formatter.format(PolyAmount.fromUnitAndValue(
              PolyUnit.nanopoly, '9000000000000000000000')),
          throwsA(const TypeMatcher<ArgumentError>()));
    });
    test('simpleCurrency', () {
      final formatter = PolyFormatter.simpleCurrency();
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120)));
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000)));
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000)));
      print(formatter.format(
          PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000)));
      expect(
          formatter.format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120)),
          equals('POLY 0.000000120'));
      expect(
          formatter
              .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000)),
          equals('POLY 0.000120000'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000)),
          equals('POLY 0.120000000'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000)),
          equals('POLY 120.000000000'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000000)),
          equals('POLY 120,000.000000000'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 9007199254740991)),
          equals('POLY 9,007,199.254740991'));

      expect(
          () => formatter.format(PolyAmount.fromUnitAndValue(
              PolyUnit.nanopoly, 9000000000000000000)),
          throwsA(const TypeMatcher<ArgumentError>()));
    });
    test('simpleCurrencyEU', () {
      final formatter =
          PolyFormatter.simpleCurrency(locale: 'eu', name: 'POLY');
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120)));
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000)));
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000)));
      print(formatter.format(
          PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000)));
      expect(
          formatter.format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120)),
          equals('0,000000120 POLY'));
      expect(
          formatter
              .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000)),
          equals('0,000120000 POLY'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000)),
          equals('0,120000000 POLY'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000)),
          equals('120,000000000 POLY'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000000)),
          equals('120.000,000000000 POLY'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 9007199254740991)),
          equals('9.007.199,254740991 POLY'));

      expect(
          () => formatter.format(PolyAmount.fromUnitAndValue(
              PolyUnit.nanopoly, 9000000000000000000)),
          throwsA(const TypeMatcher<ArgumentError>()));
    });
    test('compactSimpleCurrency', () {
      final formatter = PolyFormatter.compactSimpleCurrency();
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120)));
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000)));
      print(formatter
          .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000)));
      print(formatter.format(
          PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000)));
      expect(
          formatter.format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120)),
          equals('POLY 0.000000120'));
      expect(
          formatter
              .format(PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000)),
          equals('POLY 0.000120000'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000)),
          equals('POLY 0.120000000'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000)),
          equals('POLY 120'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 120000000000000)),
          equals('POLY 120K'));
      expect(
          formatter.format(
              PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, 9007199254740991)),
          equals('POLY 9.01M'));

      expect(
          () => formatter.format(PolyAmount.fromUnitAndValue(
              PolyUnit.nanopoly, 9000000000000000000)),
          throwsA(const TypeMatcher<ArgumentError>()));

      expect(
          () => formatter.format(PolyAmount.fromUnitAndValue(
              PolyUnit.nanopoly, '9000000000000000000000')),
          throwsA(const TypeMatcher<ArgumentError>()));
    });
  });
}
