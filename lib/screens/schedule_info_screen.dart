import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/data/schedule_data.dart';

class ScheduleInfoScreen extends StatelessWidget {
  const ScheduleInfoScreen({super.key, required this.dayInfo});

  final ScheduleData? dayInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(dayInfo?.breakfast ?? "Nincs reggeli"),
        Text(dayInfo?.beforenoonTask ?? "Nincs délelőtti feladat"),
        Text(dayInfo?.lunch ?? "Nincs ebéd"),
        Text(dayInfo?.afternoonTask ?? "Nincs délutáni feladat"),
        Text(dayInfo?.dinner ?? "Nincs vacsora"),
        Text(dayInfo?.nightTask ?? "Nincs éjszakai feladat"),
      ],
    );
  }
}
