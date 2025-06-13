import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:utsuas/booking1.dart';
import 'package:utsuas/home.dart';
import 'package:utsuas/login.dart';
import 'package:utsuas/mypet.dart';
import 'package:utsuas/personal_information.dart';
import 'package:utsuas/riwayat_medis.dart';
import 'package:utsuas/setting.dart';

class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({super.key});

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  String name = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          name = data?['name'] ?? '';
          phone = data?['phone'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? colorScheme.background : const Color(0xFF6D4C41),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Center(
            child: Text(
              'Profil Owner',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              'https://i.pinimg.com/736x/58/65/76/5865766757400485503acf67f66a8f53.jpg',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name.isNotEmpty ? name : 'Loading...',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            phone.isNotEmpty ? phone : '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? colorScheme.surface : theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ListView(
                children: [
                  buildMenuItem(context, Icons.person, 'Personal Information', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInformationPage()));
                  }),
                  buildMenuItem(context, Icons.pets, 'My Pet', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPetPage()));
                  }),
                  buildMenuItem(context, Icons.settings, 'Setting', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                  }),
                  const Divider(),
                  buildMenuItem(context, Icons.logout, 'Keluar', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  }, isLogout: true),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: theme.disabledColor,
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingPage()));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MedicalHistoryPage()));
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OwnerProfilePage()));
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profil'),
        ],
      ),
    );
  }

  Widget buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : theme.iconTheme.color,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isLogout ? Colors.red : (isDarkMode ? Colors.white : colorScheme.onSurface),
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
      onTap: onTap,
    );
  }
}
