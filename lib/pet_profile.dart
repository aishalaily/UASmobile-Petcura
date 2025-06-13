import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utsuas/edit_pet.dart';
import 'package:utsuas/detail_riwayat.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utsuas/detail_riwayat.dart';

class PetProfilePage extends StatefulWidget {
  final String petId;

  const PetProfilePage({
    super.key,
    required this.petId,
  });

  @override
  _PetProfilePageState createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  bool isLoading = true;

  String petName = '';
  String petType = '';
  String age = '';
  String gender = '';
  String weight = '';
  String birthday = '';
  String? imageUrl;

  final medicalHistory = [
    {
      "icon": "vaccines",
      "category": "Vaksinasi",
      "title": "Vaksinasi Rabies",
      "doctor": "Dr. Sarah Wilson",
      "date": "15 Maret 2025",
    },
    {
      "icon": "stethoscope",
      "category": "Check Up",
      "title": "Check Up Rutin",
      "doctor": "Dr. John",
      "date": "10 Maret 2025",
    },
    {
      "icon": "favorite",
      "category": "Operasi",
      "title": "Operasi",
      "doctor": "Dr. Emely",
      "date": "5 Maret 2025",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(widget.petId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        petName = data['name'] ?? '';
        petType = data['breed'] ?? '';
        age = data['age'] ?? '';
        gender = data['gender'] ?? '';
        weight = data['weight'] ?? '';
        birthday = data['birthday'] ?? '';
        imageUrl = data['imageUrl'];
        isLoading = false;
      });
    }
  }

  void _editPetProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPetProfilePage(
          name: petName,
          type: petType,
          age: age,
          gender: gender,
          weight: weight,
          birthday: birthday,
        ),
      ),
    );

    if (result != null) {
      // Update Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(widget.petId)
            .update({
          'name': result['name'],
          'breed': result['type'],
          'age': result['age'],
          'gender': result['gender'],
          'weight': result['weight'],
          'birthday': result['birthday'],
        });

        // Refresh UI
        setState(() {
          petName = result['name'];
          petType = result['type'];
          age = result['age'];
          gender = result['gender'];
          weight = result['weight'];
          birthday = result['birthday'];
        });
      }
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case "vaccines":
        return Icons.vaccines;
      case "stethoscope":
        return FontAwesomeIcons.stethoscope;
      case "favorite":
        return Icons.favorite;
      default:
        return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFF6F4A43),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Pet Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null ? const Icon(Icons.pets, size: 50) : null,
          ),
          const SizedBox(height: 10),
          Text(
            petName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Text(
            petType,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _editPetProfile,
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Profile"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? const Color(0xFFD0A67D) : const Color(0xFF6D4C41),
                        foregroundColor: isDarkMode ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size.fromHeight(40),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.black : Colors.brown[50],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow("Age", age),
                          _buildDetailRow("Gender", gender),
                          _buildDetailRow("Weight", weight),
                          _buildDetailRow("Birthday", birthday),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Riwayat Medis",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...medicalHistory.map((item) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.brown,
                            child: Icon(_getIcon(item['icon'] ?? ''), color: Colors.white),
                          ),
                          title: Text(item['title'] ?? ''),
                          subtitle: Text("${item['category']} - ${item['doctor']}"),
                          trailing: Text(item['date'] ?? ''),
                          // onTap: () {
                          //   Navigator.push(
                          //     context,
                          //     // MaterialPageRoute(builder: (_) => const DetailMedicalRecordPage()),
                          //   );
                          // },
                        )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
