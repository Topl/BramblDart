import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/model/box/asset_code.dart';
import 'package:mubrambl/src/model/box/security_root.dart';

abstract class TokenValueHolder {
  final int quantity;
  TokenValueHolder(this.quantity);
}

class SimpleValue extends TokenValueHolder {
  final int valueTypePrefix = 1;
  final String valueTypeString = 'Simple';
  SimpleValue(int quantity) : super(quantity);
}

class AssetValue extends TokenValueHolder {
  @override
  final int quantity;
  final AssetCode assetCode;
  final SecurityRoot? securityRoot;
  final String? metadata;

  final int valueTypePrefix = 2;
  final String valueTypeString = 'Asset';

// bytes (34 bytes for issuer Address + 8 bytes for asset short name)
  final int assetCodeSize = ToplAddress.addressSize + 8;
  final int metadataLimit = 127; // bytes of Latin-1 encoded string

  AssetValue(this.quantity, this.assetCode, this.securityRoot, this.metadata)
      : super(quantity);
}
