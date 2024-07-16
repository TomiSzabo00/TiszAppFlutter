enum AudienceVotingState {
  paused,
  voting,
  stopped,
}

extension RawValuesExtension on AudienceVotingState {
  static const rawValues = {
    AudienceVotingState.paused: 'paused',
    AudienceVotingState.voting: 'voting',
    AudienceVotingState.stopped: 'stopped',
  };

  String get rawValue => rawValues[this] ?? 'stopped';

  static AudienceVotingState fromRawValue(String rawValue) {
    return rawValues.entries
        .firstWhere(
          (element) => element.value == rawValue,
          orElse: () => const MapEntry(AudienceVotingState.stopped, ""),
        )
        .key;
  }

  String get displayValue {
    switch (this) {
      case AudienceVotingState.paused:
        return 'szünetel';
      case AudienceVotingState.voting:
        return 'folyamatban van';
      case AudienceVotingState.stopped:
        return 'nincs elindítva';
    }
  }
}
