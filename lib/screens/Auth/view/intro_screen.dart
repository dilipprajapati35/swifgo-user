import 'package:flutter/material.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/app_primary_button.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/screens/Auth/view/login/login_screen.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:nb_utils/nb_utils.dart';


class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          Image.asset(
            AppAssets.intro1,
            width: context.width(),
            height: context.height() * 0.52,
          ),
          34.height,
          Expanded(
            child: Container(
              width: context.width(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Making your drive\nbest is our\nresponsibility',
                    style: AppStyle.largeTitle,
                  ),
                  4.height,
                  Text(
                    'Swift Go – Move Fast. Ride Smart.',
                    style: AppStyle.subheading,
                  ),
                  16.height,
                  Row(
                    children: const [
                      Dot(isActive: true),
                      Dot(),
                      Dot(),
                      Dot(),
                    ],
                  ),
                  Spacer(),
                  AppPrimaryButton(
                    text: 'Get Started',
                    icon: Icons.arrow_forward,
                    onTap: () {
                      PhoneVerificationScreen().launch(context);
                    },
                  ),
                  24.height,
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text:
                            'By continuing, you agree that you have read and accept our ',
                        style: AppStyle.caption1w400,
                        children: [
                          TextSpan(
                            text: 'T&Cs',
                            style: AppStyle.caption1w600.copyWith(
                                color: AppColor.greyShade2,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: AppStyle.caption1w600.copyWith(
                                color: AppColor.greyShade2,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final bool isActive;
  const Dot({super.key, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: isActive ? 18 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? AppColor.buttonColor : AppColor.greyShade1,
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}
