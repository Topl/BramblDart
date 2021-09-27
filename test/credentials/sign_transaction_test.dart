import 'package:bip_topl/bip_topl.dart';
import 'package:mubrambl/src/core/amount.dart';
import 'package:mubrambl/src/core/client.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/credentials/credentials.dart';
import 'package:mubrambl/src/model/box/box.dart';
import 'package:mubrambl/src/model/box/box_id.dart';
import 'package:mubrambl/src/model/box/recipient.dart';
import 'package:mubrambl/src/model/box/sender.dart';
import 'package:mubrambl/src/model/box/token_value_holder.dart';
import 'package:mubrambl/src/modifier/modifier_id.dart';
import 'package:mubrambl/src/transaction/transactionReceipt.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';
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
        id: ModifierId.create(Uint8List(MODIFIER_ID_SIZE)),
        txType: 'AssetTransfer',
        newBoxes: [
          Box.fromJson({
            'nonce': '-586686527903758527',
            'id': '58e5WCs5DvgYPQUsyzEVLkoAHRJBL5LgsPX8vxRcBDig',
            'evidence': 'YbEfzvNJ9YeaejXvhV1G4TdBrdYg1mBgzZNAwQ5TYssm',
            'type': 'PolyBox',
            'value': {'type': 'Simple', 'quantity': '999999'}
          })
        ],
        fee: PolyAmount.zero(),
        timestamp: 0,
        boxesToRemove: [
          BoxId.applyByteArray(Uint8List(BLAKE2B_256_DIGEST_SIZE))
        ],
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
              SimpleValue('0'))
        ],
        propositionType: PropositionType.ed25519());
    final messageToSign =
        'R1JphThT5KxykWcoHGm8coPkeETw6NR4uixCFX68UNWHNnKrRVi8pAkoknUCXvmvrmtDxyuXrQxdv2AyUr5iam7mqzVmSMXnA1m988ReAnQCAZPuVcTdhVCQrhFLUTNGQ85Emb3kLRaC4ymgunMt2rC6EdV9ExtGtcBz4AcCMgP9GjaussQUtxmYJeVsRJqDAAWb9YxUMmaKTXeTuSZis1RCXTKahtnkWD1rs2DS8bKeq6iJLNTj8ZS3augDgcu3K5Rk2B6gUMMrNd9g65WfguJqZjkeoPcs2QzsMSFdYgsNEcAwtkYcCHdZtqr6iNts75U7CpoQCUr8irGUM9rSXY2mFE';

    final client = BramblClient();

    final signature = await client.signTransaction(
      key,
      transactionReceipt,
      Base58Encoder.instance.decode(messageToSign),
    );

    expect(
        TransactionReceipt.encodeSignatures(
            signature.signatures, signature.propositionType),
        {
          '148bSqf8YKaziQjefWnLVFzpw5RX1p2ren2VKY7zaXqR4zdNpacB6qcGDCFaDMMAXDiDXrRiVKp1rnwF1DxjYpKHB':
              '15VEJFr8MTj2nHHydRUdDyn743MmeCFrSh3rWzLe6SP7Mb1m52KUCaYLWM9dC4dZ9x1vbDVCBUAXyYrox6gKRx4TZ'
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
