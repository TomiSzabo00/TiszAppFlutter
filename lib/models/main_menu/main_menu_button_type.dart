enum MainMenuButtonType {
  none,
  karaoke,
  nappaliPortya,
  pictureUpload,
  pictures,
  quizQuick,
  schedule,
  scoreUpload,
  scores,
  songs,
  textUpload,
  texts,
  voting,
  wordle,
  menuButtons,
  hazasParbaj,
  notifications,
  ejjeliportya,
  slowQuiz,
  reviewPics,
}

extension RawValuesExtension on MainMenuButtonType {
  static const rawValues = {
    MainMenuButtonType.karaoke: 'karaoke',
    MainMenuButtonType.nappaliPortya: 'nappali_porty',
    MainMenuButtonType.pictureUpload: 'pic_upload',
    MainMenuButtonType.pictures: 'pics',
    MainMenuButtonType.quizQuick: 'quiz_quick',
    MainMenuButtonType.schedule: 'schedule',
    MainMenuButtonType.scoreUpload: 'score_upload',
    MainMenuButtonType.scores: 'scores',
    MainMenuButtonType.songs: 'songs',
    MainMenuButtonType.textUpload: 'text_upload',
    MainMenuButtonType.texts: 'texts',
    MainMenuButtonType.voting: 'voting',
    MainMenuButtonType.wordle: 'wordle',
    MainMenuButtonType.menuButtons: 'menu_buttons',
    MainMenuButtonType.hazasParbaj: 'hazas_parbaj',
    MainMenuButtonType.ejjeliportya: 'ejjeli_portya',
    MainMenuButtonType.notifications: 'notifications',
    MainMenuButtonType.slowQuiz: 'slow_quiz',
    MainMenuButtonType.reviewPics: 'review_pics',
  };

  String get rawValue => rawValues[this] ?? 'error';
}
