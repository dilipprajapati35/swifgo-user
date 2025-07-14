import 'package:flutter/material.dart';
import 'package:flutter_arch/theme/colorTheme.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  const MyAppbar({
    super.key,
    required this.title,
    this.onPressActionIcon,
    this.actionIcon,
    this.actionIconColor,
    this.backIcon,
    this.isBackGround,
    this.centerTitle = false,
  });

  final String title;
  final void Function()? onPressActionIcon;
  final Widget? actionIcon;
  final Color? actionIconColor;
  final IconButton? backIcon;
  final bool? isBackGround;
  final bool? centerTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      forceMaterialTransparency: !(isBackGround ?? false),
      backgroundColor:
          (isBackGround ?? false) ? AppColor.primaryColor : AppColor.background,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          color: (isBackGround ?? false) ? AppColor.constWhite : null,
        ),
      ),
      actions: actionIcon != null
          ? [
              IconButton(
                onPressed: onPressActionIcon,
                icon: actionIcon!,
                color: actionIconColor,
              ),
            ]
          : null,
      leading: backIcon,
    );
  }
}
