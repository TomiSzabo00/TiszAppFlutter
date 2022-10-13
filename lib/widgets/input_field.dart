import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    this.placeholder = "",
    required this.controller,
    this.obscureText = false,
    this.icon,
    this.isNumber = false,
  });

  final String placeholder;
  final TextEditingController controller;
  final bool obscureText;
  final Icon? icon;
  final bool isNumber;

  final _padding = 15.0;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _obscureText = true;

  @override
  void initState() {
    _obscureText = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return CupertinoTextField(
      autocorrect: false,
      enableSuggestions: false,
      controller: widget.controller,
      placeholder: widget.placeholder,
      padding: EdgeInsets.only(
        top: widget._padding,
        bottom: widget._padding,
      ),
      prefix: Padding(
        padding: EdgeInsets.all(widget._padding),
        child: widget.icon,
      ),
      decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
          backgroundBlendMode: BlendMode.plus),
      obscureText: _obscureText,
      keyboardType: widget.isNumber ? TextInputType.number : null,
      inputFormatters: widget.isNumber
          ? [
              LengthLimitingTextInputFormatter(5),
              FilteringTextInputFormatter.digitsOnly,
            ]
          : [],
      onChanged: (val) {
        if (widget.isNumber) {
          if (val.length == 5) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        }
      },
      suffix: widget.obscureText
          ? IconButton(
              icon: _obscureText
                  ? const Icon(Icons.visibility)
                  : const Icon(Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
          : null,
      style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
    );
  }
}
