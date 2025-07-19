import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/Auth/provider/loginProvider.dart';
import 'package:flutter_arch/screens/Auth/provider/registerProvider.dart';
import 'package:flutter_arch/screens/Auth/view/splash_screen.dart';
import 'package:flutter_arch/services/firebase_messenging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load environment variables with error handling
    try {
      await dotenv.load(fileName: ".env");
      print("Environment variables loaded successfully");
    } catch (e) {
      print("Failed to load .env file: $e");
      // Continue without .env file
    }
    
    // Initialize Firebase with error handling
    try {
      await Firebase.initializeApp();
      print("Firebase initialized successfully");
    } catch (e) {
      print("Failed to initialize Firebase: $e");
      // Continue without Firebase
    }
    
    // Initialize Firebase Messaging with error handling
    try {
      await FirebaseMessagingService().initialize(null);
      print("Firebase Messaging initialized successfully");
    } catch (e) {
      print("Failed to initialize Firebase Messaging: $e");
      // Continue without Firebase Messaging
    }
    
    runApp(const MyApp());
  } catch (e) {
    print("Error in main: $e");
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
      ],
      child: MaterialApp(
        title: 'Ride Go',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
