import 'package:built_collection/built_collection.dart';

///
/// BIP-0044 Multi-Account Hierarchy for Deterministic Wallets is a Bitcoin standard defining a structure
/// and algorithm to build a hierarchy tree of keys from a single root private key. Note that this is the
/// derivation scheme used by Icarus / Yoroi.
///
/// It is built upon BIP-0032 and is a direct application of BIP-0043. It defines a common representation
/// of addresses as a multi-level tree of derivations:
///
///    m / purpose' / coin_type' / account_ix' / change_chain / address_ix
///
/// Where m is the private key, purpose is 1852 since this is an implementation of the CIP-1852 wallet protocol, coin_type is 7091 for TOPL, account_ix is a zero-
/// based index defaulting to 0, change_chain is generaly 1 for change, address_ix is a zero-based index
/// defaulting to 0.

abstract class Addresses {
  static final String defaultPurpose = '1852';
  static final String defaultCoin = '7091';
  static final int defaultAddressIdx = 0;
  String get purpose;
  String get coinType;
  String get addressIdx;
  String get masterPrivateKey;
  String get masterPublicKey;
  BuiltList<String> get addresses;
  BuiltList<String> get boxes;
}
