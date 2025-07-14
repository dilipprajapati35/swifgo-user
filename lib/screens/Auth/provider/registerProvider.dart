import 'package:flutter/material.dart';
import 'package:flutter_arch/enums/returnCodeEnum.dart';
import 'package:flutter_arch/screens/Auth/model/authModel.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:flutter_arch/storage/flutter_secure_storage.dart';
import 'package:flutter_arch/widget/snack_bar.dart';

class RegisterProvider extends ChangeNotifier {
  // Text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  // Services
  final DioHttp _dioHttp = DioHttp();
  final MySecureStorage _secureStorage = MySecureStorage();

  bool isLoading = false;

  String? usernameError;
  String? emailError;
  String? mobileError;
  String? passwordError;

  bool usernameFocused = false;
  bool emailFocused = false;
  bool mobileFocused = false;
  bool passwordFocused = false;

  RegisterProvider() {
    usernameController.addListener(_validateUsernameOnChange);
    emailController.addListener(_validateEmailOnChange);
    mobileController.addListener(_validateMobileOnChange);
    passController.addListener(_validatePasswordOnChange);
  }

  void setUsernameFocus(bool focused) {
    usernameFocused = focused;
    if (!focused && usernameController.text.isNotEmpty) {
      usernameError = validateUsername(usernameController.text);
      notifyListeners();
    }
  }

  void setEmailFocus(bool focused) {
    emailFocused = focused;
    if (!focused && emailController.text.isNotEmpty) {
      emailError = validateEmail(emailController.text);
      notifyListeners();
    }
  }

  void setMobileFocus(bool focused) {
    mobileFocused = focused;
    if (!focused && mobileController.text.isNotEmpty) {
      mobileError = validateMobile(mobileController.text);
      notifyListeners();
    }
  }

  void setPasswordFocus(bool focused) {
    passwordFocused = focused;
    if (!focused && passController.text.isNotEmpty) {
      passwordError = validatePassword(passController.text);
      notifyListeners();
    }
  }

  void _validateUsernameOnChange() {
    usernameError = validateUsername(usernameController.text);
    notifyListeners();
  }

  void _validateEmailOnChange() {
    emailError = validateEmail(emailController.text);
    notifyListeners();
  }

  void _validateMobileOnChange() {
    mobileError = validateMobile(mobileController.text);
    notifyListeners();
  }

  void _validatePasswordOnChange() {
    passwordError = validatePassword(passController.text);
    notifyListeners();
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a mobile number';
    }
    final mobileRegex = RegExp(r'^\d{10}$');
    if (!mobileRegex.hasMatch(value)) {
      return 'Please enter a valid 10-digit number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    // For stronger password validation
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

    if (!hasUppercase) {
      return 'Password must contain uppercase letter';
    }
    if (!hasDigit) {
      return 'Password must contain a number';
    }
    if (!hasSpecialChar) {
      return 'Password must contain special character';
    }
    return null;
  }

  Future<void> register(BuildContext context) async {
    // usernameError = validateUsername(usernameController.text);
    // emailError = validateEmail(emailController.text);
    // mobileError = validateMobile(mobileController.text);
    // passwordError = validatePassword(passController.text);
    // if (usernameError != null ||
    //     emailError != null ||
    //     mobileError != null ||
    //     passwordError != null) {
    //   notifyListeners();
    //   return;
    // }

    // try {
    //   isLoading = true;
    //   notifyListeners();

    //   final response = await _dioHttp.register(
    //     context,
    //     usernameController.text,
    //     emailController.text,
    //     mobileController.text,
    //     passController.text,
    //   );

    //   isLoading = false;
    //   final authModel = AuthModel.fromJson(response.data);

    //   if (authModel.dataResponse.returnCode == ReturnCodes.R_SUCCESS.value) {
    //     MySnackBar.showSnackBar(context, "Registration successful");
    //     context.go('/login');
    //   } else {
    //     MySnackBar.showSnackBar(context, authModel.dataResponse.description);
    //   }
    // } catch (e) {
    //   isLoading = false;
    //   MySnackBar.showSnackBar(
    //       context, "Registration failed. Please try again.");
    // }

    // notifyListeners();
  }

  @override
  void dispose() {
    usernameController.removeListener(_validateUsernameOnChange);
    emailController.removeListener(_validateEmailOnChange);
    mobileController.removeListener(_validateMobileOnChange);
    passController.removeListener(_validatePasswordOnChange);
    usernameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passController.dispose();
    super.dispose();
  }
}
