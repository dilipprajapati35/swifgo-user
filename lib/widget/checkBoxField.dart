import 'package:flutter/material.dart';

class MyCheckboxField extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;

  const MyCheckboxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (bool? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          activeColor: Colors.white,
          checkColor: Colors.blue,
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
