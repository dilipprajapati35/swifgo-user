import 'package:flutter_arch/helpers/text_style.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: primarybold22,),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(cancelText, style: primary16),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(confirmText,  style: primary16),
        ),
      ],
    );
  }
}