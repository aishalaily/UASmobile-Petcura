import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:utsuas/notifikasi.dart';
import 'package:utsuas/profil.dart';
import 'package:utsuas/help.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan tema yang sedang digunakan
    final theme = Provider.of<ThemeProvider>(context);
    final isLightMode = theme.themeMode == ThemeMode.light;

    return Scaffold(
      backgroundColor: isLightMode ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isLightMode ? Colors.white : Colors.black,
        title: Text(
          'Settings',
          style: TextStyle(
            color: isLightMode ? Colors.black : Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(
                Icons.brightness_6,
                color: isLightMode ? Colors.black : Colors.white,
              ),
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  color: isLightMode ? Colors.black : Colors.white,
                ),
              ),
              trailing: Switch(
                value: !isLightMode,
                onChanged: (value) {
                  theme.toggleTheme();
                },
              ),
            ),

            ListTile(
              leading: Icon(
                Icons.notifications,
                color: isLightMode ? Colors.black : Colors.white,
              ),
              title: Text(
                'Notifications',
                style: TextStyle(
                  color: isLightMode ? Colors.black : Colors.white,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingNotificationPage()),
                );
              },
            ),

            // Account Settings
            ListTile(
              leading: Icon(
                Icons.account_circle,
                color: isLightMode ? Colors.black : Colors.white,
              ),
              title: Text(
                'Account',
                style: TextStyle(
                  color: isLightMode ? Colors.black : Colors.white,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OwnerProfilePage()),
                );
              },
            ),


            // Help & Support
            ListTile(
              leading: Icon(
                Icons.help_outline,
                color: isLightMode ? Colors.black : Colors.white,
              ),
              title: Text(
                'Help & Support',
                style: TextStyle(
                  color: isLightMode ? Colors.black : Colors.white,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportPage()),
                );
              },

            ),
          ],
        ),
      ),
    );
  }
}
