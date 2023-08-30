import 'package:tiszapp_flutter/models/pics/picture_category.dart';

class Filter {
  int? teamNum;
  PictureCategory? category;
  DateFilter? date;
  bool? isPicOfTheDay;

  Filter({this.teamNum, this.category, this.date, this.isPicOfTheDay})
      : assert(
            teamNum != null ||
                category != null ||
                date != null ||
                isPicOfTheDay != null,
            'Filter must have at least one parameter');

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Filter &&
          runtimeType == other.runtimeType &&
          teamNum == other.teamNum &&
          category == other.category &&
          date == other.date &&
          isPicOfTheDay == other.isPicOfTheDay;
}

enum DateFilter { today, yesterday, earlier }

extension DateFilterExtension on DateFilter {
  String get displayName {
    switch (this) {
      case DateFilter.today:
        return 'Ma';
      case DateFilter.yesterday:
        return 'Tegnap';
      case DateFilter.earlier:
        return 'Korábbi';
    }
  }
}
