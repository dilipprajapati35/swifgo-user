import 'package:flutter/material.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/app_primary_button.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/screens/Auth/view/registration/selfie_verification.screen.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:flutter_arch/storage/flutter_secure_storage.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:flutter_arch/widget/snack_bar.dart';
import 'package:nb_utils/nb_utils.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _genderController = TextEditingController();
  final _residenceController = TextEditingController();
  final _workController = TextEditingController();
  final _timingController = TextEditingController();

  String? selectedGender = 'male';
  final List<String> genderOptions = ['male', 'female', 'other'];

  bool isLoading = false;
  DioHttp dio = DioHttp();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyShade7,
      resizeToAvoidBottomInset: true,
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
            Text('Registration', style: AppStyle.title)
                .paddingSymmetric(horizontal: 16),
            8.height,
            Text('Please enter all the details', style: AppStyle.subheading)
                .paddingSymmetric(horizontal: 16),
            17.height,
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name *',
                      hint: 'Enter your full name',
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email',
                    ),
                    _buildGenderDropdown(),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your Password',
                    ),
                    _buildTextField(
                      controller: _residenceController,
                      label: 'Residential location',
                      hint: 'Enter here',
                    ),
                    _buildTextField(
                      controller: _workController,
                      label: 'Work location',
                      hint: 'Enter here',
                    ),
                    _buildTimePickerField(),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: AppPrimaryButton(
                text: 'Register now',
                onTap: () async {
                  await _handleRegistration();
                },
              ).paddingSymmetric(horizontal: 16, vertical: 16),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      MySnackBar.showSnackBar(context, "Email and password are required");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final storage = MySecureStorage();
      final userId = await storage.readUserId();

      if (userId == null) {
        MySnackBar.showSnackBar(
            context, "User ID not found. Please complete verification first.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await dio.completeregistration(
        context,
        userId,
        _fullNameController.text,
        _emailController.text,
        selectedGender ?? '',
        _passwordController.text,
        _residenceController.text,
        _workController.text,
        _timingController.text.isEmpty ? '00:00' : _timingController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201 && response.data['accessToken'] != null) {
        SelfieUploadScreen().launch(context);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      MySnackBar.showSnackBar(
          context, "Registration failed. Please try again.");
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            labelText: label,
            floatingLabelStyle: AppStyle.caption1w600
                .copyWith(color: AppColor.greyShade1, letterSpacing: 0),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            alignLabelWithHint: true,
            hintStyle: AppStyle.body.copyWith(
                color: AppColor.greyTextField,
                fontSize: 16,
                height: 22 / 16,
                letterSpacing: 0,
                fontWeight: FontWeight.w400),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.greyShade5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.greyShade5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.buttonColor, width: 1.5),
            ),
          ),
        ),
        16.height,
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: selectedGender,
          decoration: InputDecoration(
            hintText: 'Select Gender',
            labelText: 'Gender',
            floatingLabelStyle: AppStyle.caption1w600
                .copyWith(color: AppColor.greyShade1, letterSpacing: 0),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            alignLabelWithHint: true,
            hintStyle: AppStyle.body.copyWith(
                color: AppColor.constBlack,
                fontSize: 16,
                height: 22 / 16,
                letterSpacing: 0,
                fontWeight: FontWeight.w400),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.greyShade5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.greyShade5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.buttonColor, width: 1.5),
            ),
          ),
          items: genderOptions.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(
                gender[0].toUpperCase() + gender.substring(1),
                style: AppStyle.body.copyWith(
                  fontSize: 16,
                  height: 22 / 16,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w400,
                  color: AppColor.constBlack,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedGender = value;
              _genderController.text = value ?? '';
            });
          },
        ),
        16.height,
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  Widget _buildTimePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _timingController,
          readOnly: true,
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: Colors.white,
                      hourMinuteTextColor: AppColor.buttonColor,
                      hourMinuteColor: AppColor.buttonColor.withOpacity(0.1),
                      dialHandColor: AppColor.buttonColor,
                      dialBackgroundColor: AppColor.buttonColor.withOpacity(0.1),
                      dialTextColor: AppColor.buttonColor,
                      entryModeIconColor: AppColor.buttonColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (pickedTime != null) {
              String formattedTime =
                  '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
              setState(() {
                _timingController.text = formattedTime;
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Select preferred timing',
            labelText: 'Preferred timing',
            floatingLabelStyle: AppStyle.caption1w600
                .copyWith(color: AppColor.greyShade1, letterSpacing: 0),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            alignLabelWithHint: true,
            hintStyle: AppStyle.body.copyWith(
                color: AppColor.greyTextField,
                fontSize: 16,
                height: 22 / 16,
                letterSpacing: 0,
                fontWeight: FontWeight.w400),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.greyShade5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.greyShade5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.buttonColor, width: 1.5),
            ),
            suffixIcon: Icon(
              Icons.access_time,
              color: AppColor.buttonColor,
            ),
          ),
        ),
        16.height,
      ],
    ).paddingSymmetric(horizontal: 16);
  }
}