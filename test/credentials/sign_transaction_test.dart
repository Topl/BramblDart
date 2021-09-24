import 'package:bip_topl/bip_topl.dart';
import 'package:mubrambl/src/core/client.dart';
import 'package:mubrambl/src/credentials/credentials.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';
import 'package:pinenacl/api.dart';
import 'package:pinenacl/encoding.dart';
import 'package:test/test.dart';

void main() {
  test('signs transactions', () async {
    final credentials = ToplSigningKey(
        Bip32SigningKey(HexCoder.instance.decode(
            '60d399da83ef80d8d4f8d223239efdc2b8fef387e1b5219137ffb4e8fbdea15adc9366b7d003af37c11396de9a83734e30e05e851efa32745c9cd7b42712c890608763770eddf77248ab652984b21b849760d1da74a6f5bd633ce41adceef07a')),
        0x01,
        PropositionType.ed25519());
    final messageToSign =
        'R1JphThT5KxykWcoHGm8coPkeETw6NR4uixCFX68UNWHNnKrRVi8pAkoknUCXvmvrmtDxyuXrQxdv2AyUr5iam7mqzVmSMXnA1m988ReAnQCAZPuVcTdhVCQrhFLUTNGQ85Emb3kLRaC4ymgunMt2rC6EdV9ExtGtcBz4AcCMgP9GjaussQUtxmYJeVsRJqDAAWb9YxUMmaKTXeTuSZis1RCXTKahtnkWD1rs2DS8bKeq6iJLNTj8ZS3augDgcu3K5Rk2B6gUMMrNd9g65WfguJqZjkeoPcs2QzsMSFdYgsNEcAwtkYcCHdZtqr6iNts75U7CpoQCUr8irGUM9rSXY2mFE';

    final client = BramblClient();

    final signature = await client.signTransaction(
        credentials, Base58Encoder.instance.decode(messageToSign));

    expect(Base58Encoder.instance.encode(signature),
        'Ac68CBLFtoF3SRHtyzx6UBDgpkMnt4GnVNXCFvykr4FsPMEkPraJoa4xMAHqpgAxSAhkyB6MdNXq1sXvf2Nc5vFy');
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
