import 'package:flutter/material.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:nb_utils/nb_utils.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double height;
  final double borderRadius;
  final IconData? icon;

  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height = 56,
    this.borderRadius = 16,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: context.width(),
        decoration: BoxDecoration(
            color: AppColor.buttonColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColor.greyShade2,
                spreadRadius: 0,
                blurRadius: 3,
                offset: Offset(0, -3),
              ),
            ]),
        child: Center(
          child: Row(
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: Colors.transparent,
                ).paddingOnly(left: 16),
              Spacer(),
              Text(
                text,
                style: AppStyle.body,
              ),
              Spacer(),
              if (icon != null)
                Icon(
                  icon,
                  color: AppColor.greyWhite,
                ).paddingOnly(right: 16),
            ],
          ),
        ),
      ),
    );
  }
}
