/// Library to create and unlock Topl Wallets and operate with private keys.
//ignore_for_file: directives_ordering
library credentials;

import 'dart:convert';
import 'dart:typed_data';

import 'package:bip_topl/bip_topl.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:brambldart/crypto.dart';
import 'package:brambldart/model.dart';
import 'package:brambldart/utils.dart';
import 'package:pinenacl/api.dart';
import 'package:pinenacl/api/signatures.dart';
import 'package:pinenacl/encoding.dart';
import 'package:pinenacl/key_derivation.dart';

part 'src/credentials/address.dart';
part 'src/credentials/address_chain.dart';
part 'src/credentials/addresses.dart';
part 'src/credentials/credentials.dart';
part 'src/credentials/hd_wallet_helper.dart';
part 'src/credentials/seed.dart';
part 'src/attestation/address_codec.dart';
