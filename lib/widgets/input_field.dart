import 'package:flutter/cupertino.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    this.placeholder = "",
    required this.controller,
    this.obscureText = false,
    this.icon,
  });

  final String placeholder;
  final TextEditingController controller;
  final bool obscureText;
  final Icon? icon;

  final _padding = 15.0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      prefix: Padding(
        padding: EdgeInsets.all(_padding),
        child: icon,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      obscureText: obscureText,
    );
  }
}
