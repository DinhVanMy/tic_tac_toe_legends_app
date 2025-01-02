import 'package:flutter/material.dart';

class TextFieldCustomWidget extends StatelessWidget {
  final double fieldHeight;
  final String labelText;
  final Function(String)? onChanged;
  final int? maxLength;
  const TextFieldCustomWidget(
      {super.key,
      required this.fieldHeight,
      required this.labelText,
      this.onChanged,
      this.maxLength});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: fieldHeight,
      child: TextField(
        onChanged: onChanged,
        minLines: null,
        maxLines: null,
        expands: true,
        textAlign: TextAlign.left,
        maxLength: maxLength,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          fillColor: Colors.transparent,
          labelText: labelText,
          alignLabelWithHint: true,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.blueAccent,
            ),
          ),
        ),
      ),
    );
  }
}
