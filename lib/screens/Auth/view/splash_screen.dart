import 'package:flutter/material.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/screens/Auth/view/intro_screen.dart';
import 'package:flutter_arch/screens/main_navigation/main_navigation.dart';
import 'package:flutter_arch/storage/flutter_secure_storage.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final MySecureStorage _secureStorage = MySecureStorage();

  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      String? token;
      try {
        token = await _secureStorage.readToken();
        print("Token: $token");
      } catch (e) {
        print("Error reading token: $e");
        token = null;
      }
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => token != null 
                ? const MainNavigation() 
                : const IntroScreen(),
          ),
        );
      }
    } catch (e) {
      print("Error in splash screen: $e");
      // Fallback navigation
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const IntroScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          AppAssets.logo,
          width: 193.07,
          height: 150,
        ),
      ),
    );
  }
}