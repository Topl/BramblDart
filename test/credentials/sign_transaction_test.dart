import 'package:bip_topl/bip_topl.dart';
import 'package:brambldart/client.dart';
import 'package:brambldart/credentials.dart';
import 'package:brambldart/model.dart';
import 'package:brambldart/src/model/box/token_value_holder.dart';
import 'package:brambldart/utils.dart';
import 'package:pinenacl/api.dart';
import 'package:pinenacl/encoding.dart';
import 'package:test/test.dart';

void main() {
  test('signs messages', () async {
    final key = ToplSigningKey(
        Bip32SigningKey(HexCoder.instance.decode(
            '60d399da83ef80d8d4f8d223239efdc2b8fef387e1b5219137ffb4e8fbdea15adc9366b7d003af37c11396de9a83734e30e05e851efa32745c9cd7b42712c890608763770eddf77248ab652984b21b849760d1da74a6f5bd633ce41adceef07a')),
        0x01,
        PropositionType.ed25519());
    final transactionReceipt = TransactionReceipt(
        id: ModifierId.create(Uint8List(modifierIdSize)),
        txType: 'AssetTransfer',
        newBoxes: [
          TokenBox.fromJson({
            'nonce': '-586686527903758527',
            'id': '58e5WCs5DvgYPQUsyzEVLkoAHRJBL5LgsPX8vxRcBDig',
            'evidence': 'YbEfzvNJ9YeaejXvhV1G4TdBrdYg1mBgzZNAwQ5TYssm',
            'type': 'PolyBox',
            'value': {'type': 'Simple', 'quantity': '999999'}
          })
        ],
        fee: PolyAmount.zero(),
        timestamp: 0,
        boxesToRemove: [BoxId.applyByteArray(Uint8List(blake2b256DigestSize))],
        from: [
          Sender(
              ToplAddress.fromBase58(
                  '3NKBoNgMRpKahSi8tC8XPetDom9bdh3NXxSpfZ8fkvDMYwFcgnK1'),
              '3945781279437276569')
        ],
        to: [
          SimpleRecipient(
              ToplAddress.fromBase58(
                  '3NKBoNgMRpKahSi8tC8XPetDom9bdh3NXxSpfZ8fkvDMYwFcgnK1'),
              SimpleValue(quantity: '0'))
        ],
        propositionType: PropositionType.ed25519());
    const messageToSign =
        'R1JphThT5KxykWcoHGm8coPkeETw6NR4uixCFX68UNWHNnKrRVi8pAkoknUCXvmvrmtDxyuXrQxdv2AyUr5iam7mqzVmSMXnA1m988ReAnQCAZPuVcTdhVCQrhFLUTNGQ85Emb3kLRaC4ymgunMt2rC6EdV9ExtGtcBz4AcCMgP9GjaussQUtxmYJeVsRJqDAAWb9YxUMmaKTXeTuSZis1RCXTKahtnkWD1rs2DS8bKeq6iJLNTj8ZS3augDgcu3K5Rk2B6gUMMrNd9g65WfguJqZjkeoPcs2QzsMSFdYgsNEcAwtkYcCHdZtqr6iNts75U7CpoQCUr8irGUM9rSXY2mFE';

    final client = BramblClient();

    final signature = await client.signTransaction(
      [key],
      transactionReceipt,
      Base58Encoder.instance.decode(messageToSign),
    );

    expect(
        TransactionReceipt.encodeSignatures(
            signature.signatures, signature.propositionType),
        {
          'KVAveekFcodVt7bUCMK6jCAqRbHTsS7gAzVMLu1ZkrrcPdorhDVRWhTZCHaAdV1vgAZ37VR1oS1RByQvtzu5DtgR':
              'Lqon4qk4kwfZkfvS73bqSySxPXY6Ff7U61rYo7f5fQYtz2C78vnXFdXrMBd9LmQZQUG6UYthwnXXwtysmiUxMdro'
        });
  });

  test('extract address', () async {
    final key = ToplSigningKey(
        Bip32SigningKey(HexCoder.instance.decode(
            '60d399da83ef80d8d4f8d223239efdc2b8fef387e1b5219137ffb4e8fbdea15adc9366b7d003af37c11396de9a83734e30e05e851efa32745c9cd7b42712c890608763770eddf77248ab652984b21b849760d1da74a6f5bd633ce41adceef07a')),
        0x01,
        PropositionType.ed25519());
    final from = await key.extractAddress();
    expect(
        from.toBase58(), '9hdk9U5NpuQaikjRroHTY9CBREL3t6dU9muL8QJRnJ4qzjmh1mu');
  });
}
