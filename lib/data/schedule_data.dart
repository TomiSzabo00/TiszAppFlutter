class ScheduleData {
  final String day;
  final String breakfast;
  final String beforenoonTask;
  final String lunch;
  final String afternoonTask;
  final String dinner;
  final String nightTask;
  final String midnightTask;

  ScheduleData(
    this.day,
    this.breakfast,
    this.beforenoonTask,
    this.lunch,
    this.afternoonTask,
    this.dinner,
    this.nightTask,
    this.midnightTask,
  );

  ScheduleData.fromJson(Map<String, dynamic> json)
      : day = json['Day'],
        breakfast = json['Breakfast'],
        beforenoonTask = json['BeforenoonTask'],
        lunch = json['Lunch'],
        afternoonTask = json['AfternoonTask'],
        dinner = json['Dinner'],
        nightTask = json['NightTask'],
        midnightTask = json['MidnightTask'];
}
