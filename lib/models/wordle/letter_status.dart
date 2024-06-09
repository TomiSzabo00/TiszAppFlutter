enum LetterStatus {
  initial,
  notInWord,
  inWord,
  correct,
}

extension LetterStatusExtension on LetterStatus {
  bool isHigher({required LetterStatus other}) => index > other.index;
}