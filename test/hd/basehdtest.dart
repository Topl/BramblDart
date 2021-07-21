import 'package:mubrambl/src/HD/base_hd.dart';
import 'package:mubrambl/src/utils/byte_utils.dart';
import 'package:test/test.dart';

const mnemonic =
    'sniff song hill jump actual sustain attend pluck clock myself sponsor monster';

const seed =
    '2c537dbc2d04ba16aadb41d9e07f73baa894989a7630d54852a79c1016588cbfdc1b4d2d83d65228f93a942877e5f87666540cdea45316d1b7d32e9e81755ce8';

void main() {
  group('Base / Default Hd: ', () {
    test('getKeysFromPath(String path)', () async {
      final hd = BaseHd.fromMnemonic(mnemonic);
      final keys0 = await hd.getKeysFromPath('m/0\'/0\'');
      expect(keys0.path, 'm/0\'/0\'');
      expect(isValidHex(keys0.publicKey), true);
      expect(isValidHex(keys0.privateKey), true);
      expect(isValidHex((keys0.chainCode!)), true);
    });

    test('getKeys(num: addressIndex, num: keyDataIndex)', () async {
      final hd = BaseHd.fromMnemonic(mnemonic);
      final keys0 = await hd.getKeys(0, 0);
      expect(isValidHex(keys0.publicKey), true);
      expect(isValidHex(keys0.privateKey), true);
      expect(isValidHex((keys0.chainCode!)), true);
    });
  });
}
