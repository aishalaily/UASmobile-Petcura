import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:utsuas/detail_riwayat.dart';
import 'package:utsuas/booking1.dart';
import 'package:utsuas/profil.dart';
import 'package:utsuas/home.dart';

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  String selectedCategory = "Semua";
  List<Map<String, dynamic>> medicalRecords = [];

  @override
  void initState() {
    super.initState();
    loadDummyData(); // Ganti dengan data dummy
    // fetchMedicalHistory(); // Nonaktifkan sementara
  }

  // Ini contoh data dummy
  void loadDummyData() {
    medicalRecords = [
      {
        "title": "Vaksin Rabies",
        "doctor": "Drh. Ani",
        "date": "2024-05-12",
        "category": "Vaksinasi",
      },
      {
        "title": "Operasi Luka",
        "doctor": "Drh. Budi",
        "date": "2024-04-30",
        "category": "Operasi",
      },
      {
        "title": "Check Up Tahunan",
        "doctor": "Drh. Clara",
        "date": "2024-03-21",
        "category": "Check Up",
      },
    ];
    setState(() {});
  }

  // Future<void> fetchMedicalHistory() async {
  //   final userId = FirebaseAuth.instance.currentUser?.uid;
  //   if (userId == null) return;
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('medical_history')
  //       .orderBy('date', descending: true)
  //       .get();
  //
  //   setState(() {
  //     medicalRecords = snapshot.docs.map((doc) => doc.data()).toList();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = selectedCategory == "Semua"
        ? medicalRecords
        : medicalRecords
            .where((record) => record["category"] == selectedCategory)
            .toList();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title: Text(
          'Riwayat Medis',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["Semua", "Vaksinasi", "Operasi", "Check Up"]
                    .map((category) {
                  final isSelected = category == selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = category),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD0A67D)
                            : (isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDarkMode ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredRecords.isEmpty
                  ? Center(
                      child: Text(
                        "Tidak ada riwayat.",
                        style: TextStyle(
                            color:
                                isDarkMode ? Colors.white : Colors.black),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailMedicalRecordPage(record),
                              ),
                            );
                          },
                          child: _medicalCard(
                            icon: _getIcon(record["category"]),
                            title: record["title"],
                            doctor: record["doctor"],
                            date: record["date"],
                            isDarkMode: isDarkMode,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD0A67D),
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BookingPage()),
              );
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const OwnerProfilePage()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Booking'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _medicalCard({
    required IconData icon,
    required String title,
    required String doctor,
    required String date,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD0A67D)),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 30, color: isDarkMode ? Colors.white : Colors.brown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black)),
                Text(doctor,
                    style: TextStyle(
                        color: isDarkMode
                            ? Colors.white70
                            : Colors.black87,
                        fontSize: 13)),
                Text(date,
                    style: TextStyle(
                        color: isDarkMode
                            ? Colors.white54
                            : Colors.black54,
                        fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  IconData _getIcon(String category) {
    switch (category) {
      case "Vaksinasi":
        return Icons.vaccines;
      case "Check Up":
        return FontAwesomeIcons.stethoscope;
      case "Operasi":
        return Icons.favorite;
      default:
        return Icons.medical_services;
    }
  }
}
