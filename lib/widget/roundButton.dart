import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:flutter/material.dart';

class Roundbutton extends StatelessWidget {
  const Roundbutton({
    super.key, 
    required this.text, 
    required this.ontap,
    this.icon,
  });
  
  final String text;
  final VoidCallback? ontap;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: ontap,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: AppColor.listBorder,
        // Add disabled styling
        disabledBackgroundColor: AppColor.listBorder.withOpacity(0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: AppColor.constBlack,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}