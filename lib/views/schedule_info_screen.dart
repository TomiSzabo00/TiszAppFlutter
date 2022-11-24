import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/schedule_data.dart';
import 'package:tiszapp_flutter/widgets/schedule_field.dart';

class ScheduleInfoScreen extends StatelessWidget {
  const ScheduleInfoScreen({super.key, required this.dayInfo});

  final ScheduleData? dayInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 160,
        ),
        ScheduleField(description: "Reggeli", value: dayInfo?.breakfast),
        ScheduleField(
            description: "Délelőtti program", value: dayInfo?.beforenoonTask),
        ScheduleField(description: "Ebéd", value: dayInfo?.lunch),
        ScheduleField(
            description: "Délutáni program", value: dayInfo?.afternoonTask),
        ScheduleField(description: "Vacsora", value: dayInfo?.dinner),
        ScheduleField(description: "Esti program", value: dayInfo?.nightTask),
      ],
    );
  }
}
