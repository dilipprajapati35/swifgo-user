import 'package:flutter/material.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:flutter_arch/storage/flutter_secure_storage.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:flutter_arch/widget/snack_bar.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class AadharOtpVerificationScreen extends StatefulWidget {
  const AadharOtpVerificationScreen(
      {super.key, this.aadhaarNumber, this.transactionId, this.testOtp});
  final String? aadhaarNumber;
  final String? transactionId;
  final String? testOtp;

  @override
  State<AadharOtpVerificationScreen> createState() =>
      _AadharOtpVerificationScreenState();
}

class _AadharOtpVerificationScreenState
    extends State<AadharOtpVerificationScreen> {
  TextEditingController otpController = TextEditingController();

  DioHttp dio = DioHttp();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Removed auto-fill functionality - users will enter OTP manually
  }

  Future<bool> verifyOtpWithApi(String otp) async {
    if (widget.aadhaarNumber != null && widget.transactionId != null) {
      setState(() {
        isLoading = true;
      });

      try {
        final response = await dio.kycverifyotp(
            context, widget.aadhaarNumber!, otp, widget.transactionId!);

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200 && response.data['user'] != null) {
          final userId = response.data['user']['id'];
          if (userId != null) {
            final storage = MySecureStorage();
            await storage.writeUserId(userId);
          }
          return true;
        }
        return false;
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        MySnackBar.showSnackBar(context, "OTP verification failed");
        return false;
      }
    }
    return false;
  }

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
            Text('Verify Aadhaar with OTP', style: AppStyle.title)
                .paddingSymmetric(horizontal: 11),
            8.height,
            RichText(
              text: TextSpan(
                style: AppStyle.subheading,
                children: [
                  const TextSpan(
                      text:
                          'An OTP has been sent to your registered mobile number linked with Aadhaar.'),
                ],
              ),
            ).paddingOnly(left: 16, right: 16),
            24.height,
            Text('Edit your Aadhar number?',
                    style: AppStyle.body.copyWith(
                        color: AppColor.buttonColor,
                        decoration: TextDecoration.underline))
                .paddingSymmetric(horizontal: 16)
                .onTap(() {
              Navigator.pop(context);
            }),
            24.height,
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: otpController,
              autoFocus: true,
              keyboardType: TextInputType.number,
              textStyle: AppStyle.title.copyWith(fontSize: 18),
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderWidth: 1,
                borderRadius: BorderRadius.circular(12),
                fieldHeight: 56,
                fieldWidth: 48,
                activeColor: AppColor.greyShade5,
                selectedColor: AppColor.buttonColor,
                inactiveColor: AppColor.greyShade5,
              ),
              onChanged: (value) async {
                if (value.length == 6) {
                  bool success = await verifyOtpWithApi(value);
                  if (success) {
                    Navigator.pop(context, 'otp_success');
                  } else {
                    Navigator.pop(context, 'otp_failed');
                  }
                }
              },
            ).paddingSymmetric(horizontal: 20),
            // Display test OTP if available
            if (widget.testOtp != null && widget.testOtp!.isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColor.buttonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.buttonColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, 
                         color: AppColor.buttonColor, 
                         size: 16),
                    8.width,
                    Expanded(
                      child: Text(
                        'Test OTP: ${widget.testOtp}',
                        style: AppStyle.body.copyWith(
                          color: AppColor.buttonColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't receive the OTP?",
                    textAlign: TextAlign.center,
                    style: AppStyle.caption1w400.copyWith(
                        color: AppColor.greyShade2,
                        fontSize: 13,
                        height: 18 / 13,
                        letterSpacing: 0)),
                TextButton(
                  onPressed: () {},
                  child: Text("Resend OTP",
                      textAlign: TextAlign.center,
                      style: AppStyle.otptxt.copyWith(
                          color: Color(0xff3E57B4),
                          fontSize: 14,
                          height: 18 / 14,
                          letterSpacing: 0)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
