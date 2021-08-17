class Proposition {
  /// the prefix of this proposition in hex
  final int propositionPrefix;

  /// the string representation of the proposition
  final String propositionName;

  const Proposition(this.propositionName, this.propositionPrefix);

  factory Proposition.Curve25519() =>
      const Proposition('PublicKeyCurve25519', 0x01);
  factory Proposition.Ed25519() => const Proposition('PublicKeyEd25519', 0x03);
}
