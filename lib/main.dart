import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/Auth/provider/loginProvider.dart';
import 'package:flutter_arch/screens/Auth/provider/registerProvider.dart';
import 'package:flutter_arch/screens/Auth/view/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
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
