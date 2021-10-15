part of 'package:brambldart/credentials.dart';

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
  static const String defaultPurpose = '1852';
  static const String defaultCoin = '7091';
  static const int defaultAddressIdx = 0;
  String get purpose;
  String get coinType;
  List<ToplAddress> get addresses;
  List<String> get boxes;
}

class AddressesImpl implements Addresses {
  final List<ToplAddress> a;
  final List<int> indexes;
  final String mPK;
  AddressesImpl(this.a, this.indexes, this.mPK);

  @override
  String get purpose => Addresses.defaultPurpose;

  @override
  String get coinType => Addresses.defaultCoin;

  @override
  List<ToplAddress> get addresses => a;

  @override
  List<String> get boxes => [];
}
