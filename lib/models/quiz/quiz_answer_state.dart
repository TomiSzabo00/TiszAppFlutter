enum QuizAnswerState {
  correct,
  incorrect,
  partiallyCorrect,
  na,
}

extension QuizAnswerStateExtension on QuizAnswerState {
  String get name {
    switch (this) {
      case QuizAnswerState.correct:
        return 'correct';
      case QuizAnswerState.incorrect:
        return 'incorrect';
      case QuizAnswerState.partiallyCorrect:
        return 'partiallyCorrect';
      case QuizAnswerState.na:
        return 'na';
      default:
        return 'na';
    }
  }
}

extension QuizAnswerStateNameExtension on String {
  QuizAnswerState get toQuizAnswerState {
    switch (this) {
      case 'correct':
        return QuizAnswerState.correct;
      case 'incorrect':
        return QuizAnswerState.incorrect;
      case 'partiallyCorrect':
        return QuizAnswerState.partiallyCorrect;
      case 'na':
        return QuizAnswerState.na;
      default:
        return QuizAnswerState.na;
    }
  }
}
