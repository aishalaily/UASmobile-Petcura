import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:utsuas/login.dart'; // ganti sesuai path login kamu
import 'package:utsuas/theme_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isLightMode = theme.themeMode == ThemeMode.light;

    return Scaffold(
      backgroundColor: isLightMode ? Colors.white : Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.paw,
              size: 60,
              color: isLightMode ? const Color(0xFFD0A67D) : Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'PETCURA',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.brown : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
