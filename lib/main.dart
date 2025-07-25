import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/Auth/view/splash_screen.dart';
import 'package:flutter_arch/services/firebase_messenging.dart';
import 'package:flutter_arch/services/socket_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print("Failed to load .env file: $e");
    }

    try {
      SocketService();
    } catch (e) {
      print("Failed to initialize Socket Service: $e");
    }
    
    try {
      await Firebase.initializeApp();
      print("Firebase initialized successfully");
    } catch (e) {
      print("Failed to initialize Firebase: $e");
    }
    
    try {
      await FirebaseMessagingService().initialize(null);
    } catch (e) {
      print("Failed to initialize Firebase Messaging: $e");
    }
    
    runApp(const MyApp());
  } catch (e) {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Go',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
