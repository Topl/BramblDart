class PropositionType {
  /// the prefix of this proposition in hex
  final int propositionPrefix;

  /// the string representation of the proposition
  final String propositionName;

  const PropositionType(this.propositionName, this.propositionPrefix);

  factory PropositionType.Curve25519() =>
      const PropositionType('PublicKeyCurve25519', 0x01);
  factory PropositionType.Ed25519() =>
      const PropositionType('PublicKeyEd25519', 0x03);
<<<<<<< HEAD
  factory PropositionType.ThresholdCurve25519() =>
      const PropositionType('ThresholdCurve255129', 0x02);
=======
>>>>>>> 05edfe811a5d4b42f3acd356836d0862e48c7313
}
