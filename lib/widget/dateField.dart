import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDateField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;
  final String? errorText;

  const MyDateField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: errorText != null
                  ? Border.all(color: Colors.red, width: 1)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                      : 'Select $label',
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black : Colors.grey,
                    fontSize: 16,
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4, left: 8),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }
}
