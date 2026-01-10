import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatefulWidget {
  final Function(String) onCodeChanged;

  const OtpInput({super.key, required this.onCodeChanged});

  @override
  _OtpInputState createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  int inputLength = 6;

  //List<String> hintText = ['P', 'I', 'N', 'K', 'Ó', 'D'];

  //create text editing controllers for all text fields
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  List<FocusNode> _focusNodes2 = [];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(inputLength, (_) => TextEditingController());
    _focusNodes = List.generate(inputLength, (_) => FocusNode());
    _focusNodes2 = List.generate(inputLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((node) => node.dispose());
    _focusNodes2.forEach((node) => node.dispose());
    super.dispose();
  }

  void _updateParentValue() {
    String code = _controllers.map((c) => c.text).join("");
    widget.onCodeChanged(code);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(inputLength, (index) {
        return buildOtpField(index);
      }),
    );
  }

  Widget buildOtpField(int index) {
    return SizedBox(
      width: 40,
      height: 60,
      child: KeyboardListener(
        focusNode: _focusNodes2[index],
        onKeyEvent: (KeyEvent event) {
          // We only care about the "Key Down" event (pressing the button)
          if (event is KeyDownEvent) {
            // Detect if the key pressed is Backspace
            if (event.logicalKey == LogicalKeyboardKey.backspace) {
              // Check if the current field is empty
              if (_controllers[index].text.isEmpty && index > 0) {
                // Move focus to the previous field
                _focusNodes[index - 1].requestFocus();
                // Optional: Clear the previous field when moving back
                _controllers[index - 1].clear();
              }
            }
          }
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          onTap: () {
            _controllers[index].selection = TextSelection.fromPosition(
              TextPosition(offset: _controllers[index].text.length),
            );
            _controllers[index].text = "";
          },
          onChanged: (value) {
            if (value.isNotEmpty && index < inputLength - 1) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else if (value.isEmpty && index > 0) {
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
            _updateParentValue();
          },
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 3.0),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 3.0, color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
