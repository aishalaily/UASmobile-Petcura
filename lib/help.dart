import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: isLightMode ? Colors.white : Colors.black,
        foregroundColor: isLightMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isLightMode ? Colors.white : Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Q: How do I change my password?\nA: Go to Account > Change Password.',
              style: TextStyle(
                color: isLightMode ? Colors.black87 : Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Q: How do I contact support?\nA: Email us at support@example.com.',
              style: TextStyle(
                color: isLightMode ? Colors.black87 : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
