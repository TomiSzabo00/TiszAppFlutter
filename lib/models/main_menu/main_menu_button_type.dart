enum MainMenuButtonType {
  none,
  karaoke,
  nappaliPortya,
  pictureUpload,
  pictures,
  quizQuick,
  schedule,
  combinedScoreUpload,
  scores,
  songs,
  textUpload,
  texts,
  voting,
  wordle,
  menuButtons,
  hazasParbaj,
  chantBlaster,
  notifications,
  ejjeliportya,
  slowQuiz,
  reviewPics,
  sports,
  sportResult,
  radioWishes,
}

extension RawValuesExtension on MainMenuButtonType {
  static const rawValues = {
    MainMenuButtonType.karaoke: 'karaoke',
    MainMenuButtonType.nappaliPortya: 'nappali_porty',
    MainMenuButtonType.pictureUpload: 'pic_upload',
    MainMenuButtonType.pictures: 'pics',
    MainMenuButtonType.quizQuick: 'quiz_quick',
    MainMenuButtonType.schedule: 'schedule',
    MainMenuButtonType.combinedScoreUpload: 'combined_score_upload',
    MainMenuButtonType.scores: 'scores',
    MainMenuButtonType.songs: 'songs',
    MainMenuButtonType.textUpload: 'text_upload',
    MainMenuButtonType.texts: 'texts',
    MainMenuButtonType.voting: 'voting',
    MainMenuButtonType.wordle: 'wordle',
    MainMenuButtonType.menuButtons: 'menu_buttons',
    MainMenuButtonType.hazasParbaj: 'hazas_parbaj',
    MainMenuButtonType.ejjeliportya: 'ejjeli_portya',
    MainMenuButtonType.chantBlaster: 'chant_blaster',
    MainMenuButtonType.notifications: 'notifications',
    MainMenuButtonType.slowQuiz: 'slow_quiz',
    MainMenuButtonType.reviewPics: 'review_pics',
    MainMenuButtonType.sports: 'sports',
    MainMenuButtonType.sportResult: 'sports_result',
    MainMenuButtonType.radioWishes: 'song_requests',
  };

  String get rawValue => rawValues[this] ?? 'error';
}
