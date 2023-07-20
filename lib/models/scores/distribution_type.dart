enum DistributionType { none, proportional, spreadOut }

extension NameExtension on DistributionType {
  String get name {
    switch (this) {
      case DistributionType.none:
        return "Sima";
      case DistributionType.proportional:
        return "Arányos";
      case DistributionType.spreadOut:
        return "N-felé osztva";
      default:
        return "Sima";
    }
  }
}
