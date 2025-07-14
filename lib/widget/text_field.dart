import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_arch/helpers/text_style.dart';
import 'package:flutter_arch/theme/colorTheme.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    this.controller,
    required this.label,
    this.obscureText,
    this.keyboardType,
    this.preFixIcon,
    this.textInputAction,
    this.suffixIcon,
    this.enabled = true,
    this.placeholderColor,
    this.onFocusChange,
    this.validator,
    this.onChanged,
    this.useFloatingLabel = false,
    this.inputFormatters,
    this.errorText,
  });

  final TextInputType? keyboardType;
  final String label;
  final bool? obscureText;
  final TextEditingController? controller;
  final Icon? preFixIcon;
  final String? errorText;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final bool enabled;
  final Color? placeholderColor;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool useFloatingLabel;
  final Function(bool)? onFocusChange;

  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // decoration: BoxDecoration(
          //   color: AppColor.inputLabelBackgroundColor,
          //   borderRadius: BorderRadius.circular(10),
          // ),
          width: double.infinity,
          child: Focus(
            onFocusChange: onFocusChange,
            child: TextFormField(
              controller: controller,
              obscureText: obscureText ?? false,
              enabled: enabled,
              validator: validator,
              onChanged: onChanged,
              textInputAction: textInputAction,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColor.inputLabelBackgroundColor,
                prefixIcon: preFixIcon,
                suffixIcon: suffixIcon,
                errorText: errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColor.secondaryColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColor.inputBorderColor,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
                // If useFloatingLabel is true, use labelText, otherwise use hintText
                hintText: useFloatingLabel ? null : label,
                labelText: useFloatingLabel ? label : null,
                floatingLabelBehavior:
                    useFloatingLabel ? FloatingLabelBehavior.auto : null,
                // Style for hint text
                hintStyle: theme.inputDecorationTheme.labelStyle?.copyWith(
                      color: placeholderColor ?? AppColor.hintText,
                    ) ??
                    TextStyle(
                      color: placeholderColor ?? AppColor.hintText,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                // Style for label text when floating
                labelStyle: TextStyle(
                  color: placeholderColor ?? AppColor.hintText,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                // Style for floating label when focused
                floatingLabelStyle: TextStyle(
                  color: AppColor.secondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: black,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget specifically for quiz form fields with floating labels
class QuizTextField extends StatelessWidget {
  const QuizTextField({
    super.key,
    this.controller,
    required this.label,
    this.obscureText,
    this.keyboardType,
    this.preFixIcon,
    this.textInputAction,
    this.suffixIcon,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.errorText,
    this.onFocusChange,
  });

  final TextInputType? keyboardType;
  final String label;
  final bool? obscureText;
  final TextEditingController? controller;
  final Icon? preFixIcon;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;
  final Function(bool)? onFocusChange;

  @override
  Widget build(BuildContext context) {
    return MyTextField(
      controller: controller,
      label: label,
      obscureText: obscureText,
      keyboardType: keyboardType,
      preFixIcon: preFixIcon,
      textInputAction: textInputAction,
      suffixIcon: suffixIcon,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      useFloatingLabel: true,
      errorText: errorText,
      onFocusChange: onFocusChange,
    );
  }
}
