import 'package:flutter/material.dart';
import 'package:flutter_arch/theme/colorTheme.dart';

class MyDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) getLabel;
  final void Function(T?) onChanged;
  final String? errorText;
  final bool isLoading;

  const MyDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.getLabel,
    required this.onChanged,
    this.errorText,
    this.isLoading = false,
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
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: errorText != null
                ? Border.all(color: Colors.red, width: 1)
                : null,
          ),
          child: isLoading
              ? Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : DropdownButtonFormField<T>(
                  value: value,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    hintText: 'Select $label',
                  ),
                  items: items.map((T item) {
                    return DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        getLabel(item),
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
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
}
