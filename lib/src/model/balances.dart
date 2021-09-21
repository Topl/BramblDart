import 'dart:convert';

import 'package:mubrambl/src/core/amount.dart';

/// The amounts for polys and arbits are displayed as 10^-9 of the respective denomination
class Balance {
  final String address;
  final PolyAmount polys;
  final ArbitAmount arbits;
  final List<AssetAmount>? assets;

  Balance(
      {required this.address,
      required this.polys,
      required this.arbits,
      this.assets});

  @override
  String toString() =>
      'Balance(address: $address, ${polys.toString()}, ${arbits.toString()}, ${json.encode(assets)}';
}
