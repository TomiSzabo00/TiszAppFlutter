import 'package:tiszapp_flutter/models/pics/picture_category.dart';

class Filter {
  int? teamNum;
  PictureCategory? category;

  Filter({this.teamNum, this.category})
      : assert(teamNum != null || category != null,
            'Filter must have at least one parameter');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Filter &&
          runtimeType == other.runtimeType &&
          teamNum == other.teamNum &&
          category == other.category;
}
