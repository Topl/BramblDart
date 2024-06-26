import 'package:brambldart/brambldart.dart';
import 'package:test/test.dart';

main() {
  test("Main Tests", () async {
    expect(true, true);
  });

  /// helper tests
  test("expectations", () async {
    final a1 = 3100.toUint8ListAuto;
    final b1 = 2847.toUint8ListAuto;
    final c1 = 11132330.toUint8ListAuto;
    final d1 = 21846.toUint8ListAuto;

    expect(a1, [100]);
  });
}
