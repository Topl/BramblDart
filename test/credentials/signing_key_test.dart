import 'dart:convert';

import 'package:mubrambl/src/credentials/credentials.dart';
import 'package:mubrambl/src/utils/network.dart';
import 'package:mubrambl/src/utils/proposition.dart';
import 'package:pinenacl/api.dart';
import 'package:pinenacl/encoding.dart';
import 'package:test/test.dart';

void main() {
  test('signs messages', () async {
    final key = ToplSigningKey(
        ByteList.fromList(HexCoder.instance.decode(
            '60d399da83ef80d8d4f8d223239efdc2b8fef387e1b5219137ffb4e8fbdea15adc9366b7d003af37c11396de9a83734e30e05e851efa32745c9cd7b42712c890608763770eddf77248ab652984b21b849760d1da74a6f5bd633ce41adceef07a')),
        Network.Toplnet(),
        Proposition.Ed25519());
    final signature =
        (await key.signToSignature(ascii.encode('Hello World'))).signature;

    expect(HexCoder.instance.encode(signature),
        '90194d57cde4fdadd01eb7cf161780c277e129fc7135b97779a3268837e4cd2e9444b9bb91c0e84d23bba870df3c4bda91a110ef735638fa7a34ea2046d4be04');
  });
}
