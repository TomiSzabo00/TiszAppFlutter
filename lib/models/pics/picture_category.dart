enum PictureCategory {
  general,
  meme,
  achievement,
  task,
}

extension PictureCategoryExtension on PictureCategory {
  String get name {
    switch (this) {
      case PictureCategory.general:
        return 'General';
      case PictureCategory.meme:
        return 'Meme';
      case PictureCategory.achievement:
        return 'Achievement';
      case PictureCategory.task:
        return 'Task';
      default:
        return 'General';
    }
  }

  String get displayName {
    switch (this) {
      case PictureCategory.general:
        return 'Általános';
      case PictureCategory.meme:
        return 'Mém';
      case PictureCategory.achievement:
        return 'Öcsívment';
      case PictureCategory.task:
        return 'Feladat';
      default:
        return 'Általános';
    }
  }
}

extension PictureCategoryExtension2 on String {
  PictureCategory get toCategory {
    switch (this) {
      case 'General':
        return PictureCategory.general;
      case 'Meme':
        return PictureCategory.meme;
      case 'Achievement':
        return PictureCategory.achievement;
      case 'Task':
        return PictureCategory.task;
      default:
        return PictureCategory.general;
    }
  }
}