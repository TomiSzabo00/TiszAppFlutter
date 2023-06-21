import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AutocompleteTextField extends StatefulWidget {
  const AutocompleteTextField({
    super.key,
    this.placeholder = "",
    required this.controller,
    required this.options,
  });

  final String placeholder;
  final TextEditingController controller;
  final List<String> options;

  @override
  State<AutocompleteTextField> createState() => _AutocompleteTextFieldState();
}

class _AutocompleteTextFieldState extends State<AutocompleteTextField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Autocomplete<String>(
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return CupertinoTextField(
          controller: textEditingController,
          focusNode: focusNode,
          placeholder: widget.placeholder,
          padding: const EdgeInsets.all(15),
          prefix: const Padding(
            padding: EdgeInsets.only(left: 15),
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
            backgroundBlendMode: BlendMode.plus,
          ),
          style: TextStyle(
            color: isDarkTheme ? CupertinoColors.white : CupertinoColors.black,
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        return widget.options.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        widget.controller.text = selection;
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: Container(
              height: 200,
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                color: isDarkTheme
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
