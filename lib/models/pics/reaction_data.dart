import 'package:tiszapp_flutter/models/pics/picture_reaction.dart';

class Reaction {
  final String userId;
  final String imageFileName;
  final PicReaction reaction;

  Reaction({
    required this.userId,
    required this.imageFileName,
    required this.reaction,
  });

  factory Reaction.fromSnapshot(Map<dynamic, dynamic> snapshot) {
    return Reaction(
      userId: snapshot['userId'],
      imageFileName: snapshot['imageFileName'],
      reaction: snapshot['reaction'].toString().toPicReaction,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'imageFileName': imageFileName,
        'reaction': reaction.name,
      };
}
