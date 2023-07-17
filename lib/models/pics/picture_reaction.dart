enum PicReaction {
  love,
  funny,
  sad,
  angry,
}

extension RawValue on PicReaction {
  String get name {
    switch (this) {
      case PicReaction.angry:
        return 'angry';
      case PicReaction.funny:
        return 'funny';
      case PicReaction.love:
        return 'love';
      case PicReaction.sad:
        return 'sad';
    }
  }
}

extension FromString on String {
  PicReaction get toPicReaction {
    switch (this) {
      case 'angry':
        return PicReaction.angry;
      case 'funny':
        return PicReaction.funny;
      case 'love':
        return PicReaction.love;
      case 'sad':
        return PicReaction.sad;
      default:
        return PicReaction.love;
    }
  }
}
