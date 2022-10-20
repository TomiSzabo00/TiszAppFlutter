import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';

class ScheduleField extends StatelessWidget {
  const ScheduleField(
      {super.key, required this.description, required this.value});

  final String description;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: const EdgeInsets.all(10.0),
      color: CustomColor.semiTransparentWhite,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              value ?? "Nincs adat",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
