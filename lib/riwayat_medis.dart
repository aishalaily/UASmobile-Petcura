import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utsuas/detail_riwayat.dart';
import 'package:utsuas/home.dart';
import 'package:utsuas/booking1.dart';
import 'package:utsuas/profil.dart';

class MedicalHistoryPage extends StatefulWidget {
  final String userId;
  const MedicalHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchDoneBookings();
  }

  void fetchDoneBookings() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: widget.userId)
        .where('status', isEqualTo: 'done')
        .get(); // Tidak pakai orderBy karena selectedDate adalah String

    List<Map<String, dynamic>> fetchedBookings = snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();

    // Urutkan secara manual berdasarkan selectedDate
    fetchedBookings.sort((a, b) {
      DateTime dateA = DateTime.parse(a['selectedDate']);
      DateTime dateB = DateTime.parse(b['selectedDate']);
      return dateB.compareTo(dateA); // descending
    });

    setState(() {
      bookings = fetchedBookings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Layanan Selesai")),
      body: bookings.isEmpty
          ? const Center(child: Text("Belum ada layanan yang selesai."))
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];
                final date = DateFormat('dd MMM yyyy')
                    .format(DateTime.parse(b['selectedDate']));

                return ListTile(
                  title: Text(b['petName'] ?? 'Hewan'),
                  subtitle: Text('${b['selectedService']} • $date'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingDetailScreen(data: b),
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD0A67D),
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // Riwayat
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Home()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => BookingPage()),
              );
              break;
            case 2:
              // stay here
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OwnerProfilePage()),
              );
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
}
