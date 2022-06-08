part of 'package:brambldart/model.dart';

/// The amounts for polys and arbits are displayed as 10^-9 of the respective denomination
///
class Balance {
  final String address;
  @PolyAmountConverter()
  final PolyAmount polys;
  @ArbitAmountConverter()
  final ArbitAmount arbits;
  @AssetAmountConverter()
  final List<AssetAmount>? assets;

  Balance({required this.address, required this.polys, required this.arbits, this.assets});

  @override
  String toString() => 'Balance(address: $address, ${polys.toString()}, ${arbits.toString()}, ${json.encode(assets)}';

  factory Balance.fromJson(Map<String, dynamic> map, String address) {
    final data = map[address] as Map<String, dynamic>;
    return Balance.fromData(data, address);
  }

  factory Balance.fromData(Map<String, dynamic> data, String address) {
    return Balance(
        address: address,
        polys: const PolyAmountConverter().fromJson(data['Balances']['Polys'] as String),
        arbits: const ArbitAmountConverter().fromJson(data['Balances']['Arbits'] as String),
        assets: (data['Boxes']['AssetBox'] as List<dynamic>)
            .map((box) => const AssetAmountConverter().fromJson(box as Map<String, dynamic>))
            .toList());
  }
}
