import 'package:flutter/material.dart';
import 'package:flutter_arch/enums/returnCodeEnum.dart';
import 'package:flutter_arch/screens/Auth/model/authModel.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:flutter_arch/storage/flutter_secure_storage.dart';

class LoginProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DioHttp _dioHttp = DioHttp();
  final MySecureStorage _secureStorage = MySecureStorage();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _errorMessage = '';

  String? emailError;
  String? passwordError;

  bool emailFocused = false;
  bool passwordFocused = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get errorMessage => _errorMessage;

  LoginProvider() {
    emailController.addListener(_validateEmailOnChange);
    passwordController.addListener(_validatePasswordOnChange);
  }

  void setEmailFocus(bool focused) {
    emailFocused = focused;
    if (!focused && emailController.text.isNotEmpty) {
      emailError = validateEmail(emailController.text);
      notifyListeners();
    }
  }

  void setPasswordFocus(bool focused) {
    passwordFocused = focused;
    if (!focused && passwordController.text.isNotEmpty) {
      passwordError = validatePassword(passwordController.text);
      notifyListeners();
    }
  }

  void _validateEmailOnChange() {
    emailError = validateEmail(emailController.text);
    notifyListeners();
  }

  void _validatePasswordOnChange() {
    passwordError = validatePassword(passwordController.text);
    notifyListeners();
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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    // emailError = validateEmail(emailController.text);
    // passwordError = validatePassword(passwordController.text);

    // if (emailError != null || passwordError != null) {
    //   notifyListeners();
    //   return;
    // }

    // _isLoading = true;
    // _errorMessage = '';
    // notifyListeners();

    // try {
    //   final response = await _dioHttp.login(
    //       context, emailController.text, passwordController.text);

    //   _isLoading = false;

    //   final dataResponse = DataResponse.fromJson(response.data['dataResponse']);

    //   if (dataResponse.returnCode == ReturnCodes.R_SUCCESS.value) {
    //     final token = response.data['data'] as String;

    //     await _secureStorage.writeToken(token);

    //     _isLoggedIn = true;
    //     notifyListeners();
    //   } else {
    //     _errorMessage = dataResponse.description;
    //     notifyListeners();
    //   }
    // } catch (e) {
    //   _isLoading = false;
    //   _errorMessage = "Login failed. Please try again.";
    //   notifyListeners();
    // }
  }

  void resetLoginState() {
    _isLoggedIn = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.removeListener(_validateEmailOnChange);
    passwordController.removeListener(_validatePasswordOnChange);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
