import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key, required this.onPressed, required this.text});
  final void Function() onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(
            AppColor.buttonColor,
          ),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColor.constWhite,
          ),
        ),
      ),
    );
  }
}
