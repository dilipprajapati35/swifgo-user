import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/app_primary_button.dart';
import 'package:flutter_arch/common/snack_bar.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/screens/Auth/view/verifywithotp.screen.dart';
import 'package:flutter_arch/screens/main_navigation/main_navigation.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';


class Complete_Kyc_Screen extends StatefulWidget {
  const Complete_Kyc_Screen({super.key});

  @override
  State<Complete_Kyc_Screen> createState() => _Complete_Kyc_ScreenState();
}

class _Complete_Kyc_ScreenState extends State<Complete_Kyc_Screen> {
  final TextEditingController _phoneController = TextEditingController();
  DioHttp dio = DioHttp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyShade7,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.arrow_back, size: 28).onTap(() {
                  Navigator.pop(context);
                }),
                Image.asset(AppAssets.logoSmall, height: 32),
              ],
            ).paddingSymmetric(horizontal: 16),
            32.height,
            Text('Complete Your KYC', style: AppStyle.title)
                .paddingSymmetric(horizontal: 16),
            8.height,
            Text('Enter your Aadhaar card number to proceed',
                    style: AppStyle.subheading)
                .paddingSymmetric(horizontal: 16),
            24.height,
            AppTextField(
              controller: _phoneController,
              textFieldType: TextFieldType.PHONE,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: 'XXXXX XXXXX',
                hintStyle: AppStyle.body.copyWith(color: AppColor.greyShade1),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.buttonColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColor.buttonColor, width: 2),
                ),
              ),
            ).paddingSymmetric(horizontal: 16),
            15.height,
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => MainNavigation()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Skip now',
                    style: AppStyle.body.copyWith(
                      color: Color(0xff3E57B4),
                    )),
              ).paddingSymmetric(horizontal: 16),
            ),
            Spacer(),
            RichText(
              text: TextSpan(
                text: 'Note: ',
                style:
                    AppStyle.caption1w600.copyWith(color: AppColor.greyShade2),
                children: [
                  TextSpan(
                    text:
                        'By proceeding, you consent to get calls, WhatsApp or SMS messages, including by automated means, from SwiftGo  and its affiliates to the number provided.',
                    style: AppStyle.caption1w400,
                  ),
                ],
              ),
            ).paddingSymmetric(horizontal: 16),
            16.height,
            AppPrimaryButton(
              text: 'Send OTP',
              onTap: () async {
                if (_phoneController.text.isEmpty) {
                  MySnackBar.showSnackBar(
                      context, "Please enter your Aadhaar number");
                  return;
                }

                try {
                  final response =
                      await dio.kycinitiate(context, _phoneController.text);
                  if (response.statusCode == 200) {
                    MySnackBar.showSnackBar(context, response.data['message']);
                    final transactionId = response.data['transactionId'];
                    String? testOtp =
                        response.data['otpForTesting']?.toString();

                    AadharOtpVerificationScreen(
                      aadhaarNumber: _phoneController.text,
                      transactionId: transactionId,
                      testOtp: testOtp, // Pass the test OTP
                    ).launch(context).then((result) {
                      if (result == 'otp_failed') {
                        _showOTPFailedDialog(context);
                      }
                      if (result == 'otp_success') {
                        _showOTPSUCCESSDialog(context);
                      }
                    });
                  }
                } catch (e) {
                  MySnackBar.showSnackBar(
                      context, "Failed to send OTP. Please try again.");
                }
              },
            ).paddingSymmetric(horizontal: 16, vertical: 16),
          ],
        ),
      ),
    );
  }
}

void _showOTPFailedDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.3),
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (ctx, anim1, anim2) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Center(
          child: Dialog(
            elevation: 5,
            surfaceTintColor: Colors.white,
            shadowColor: Colors.black,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            child: Container(
              height: context.height() * 0.37,
              width: context.width(),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    20.height,
                    Image.asset(
                      'assets/images/fail.png',
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                    16.height,
                    Text(
                      'Verification Failed',
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          color: Color(0xff101828),
                          fontWeight: FontWeight.w700),
                    ),
                    8.height,
                    Text(
                      'The OTP entered is incorrect or expired. Please try again.',
                      style: GoogleFonts.nunito(
                          height: 20 / 14,
                          fontSize: 14,
                          color: Color(0xff667085),
                          fontWeight: FontWeight.w500),
                    ),
                    24.height,
                    button('Retry OTP', () {
                      AadharOtpVerificationScreen()
                          .launch(context)
                          .then((result) {
                        if (result == 'otp_failed') {
                          _showOTPFailedDialog(context);
                        }
                      });
                    }, context, 0xffD92D20, 0xffD92D20, Colors.white),
                    12.height,
                    button('Change Aadhaar Number', () {
                      Navigator.pop(context);
                    }, context, 0xffFFFFFF, 0xffD0D5DD, Color(0xff344054))
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  ;
}

Widget button(String text, VoidCallback onTap, BuildContext context, int color,
    int bordercolor, Color textcolor) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44,
      width: context.width(),
      decoration: BoxDecoration(
        color: Color(color),
        border: Border.all(color: Color(bordercolor)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: AppStyle.body.copyWith(color: textcolor),
        ),
      ),
    ),
  );
}

void _showOTPSUCCESSDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.3),
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (ctx, anim1, anim2) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Center(
          child: Dialog(
            elevation: 5,
            surfaceTintColor: Colors.white,
            shadowColor: Colors.black,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            child: Container(
              height: context.height() * 0.3,
              width: context.width(),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    20.height,
                    Image.asset(
                      'assets/images/success.png',
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                    16.height,
                    Text(
                      'KYC Verified Successfully',
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          color: Color(0xff101828),
                          fontWeight: FontWeight.w700),
                    ),
                    8.height,
                    Text(
                      'Your Aadhaar has been successfully verified. You can now continue.',
                      style: GoogleFonts.nunito(
                          height: 20 / 14,
                          fontSize: 14,
                          color: Color(0xff667085),
                          fontWeight: FontWeight.w500),
                    ),
                    24.height,
                    button('Continue', () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainNavigation(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }, context, 0xff3E57B4, 0xff3E57B4, Colors.white),
                    12.height,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
