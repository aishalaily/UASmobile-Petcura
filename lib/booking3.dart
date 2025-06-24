import 'package:flutter/material.dart';
import 'package:utsuas/home.dart';
import 'package:utsuas/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ConfirmationPage extends StatelessWidget {
  final String ownerName;
  final String ownerPhone;
  final String petName;
  final String petAge;
  final String? petBreed;
  final String selectedSchedule;
  final String selectedService;
  final String doctorOnDuty;
  final double servicePrice;
  final DateTime selectedDate;

  const ConfirmationPage({
    Key? key,
    required this.ownerName,
    required this.ownerPhone,
    required this.petName,
    required this.petAge,
    required this.petBreed,
    required this.selectedSchedule,
    required this.selectedService,
    required this.doctorOnDuty,
    required this.servicePrice,
    required this.selectedDate,
  }) : super(key: key);

  Widget buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16),
                children: [
                  TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  TextSpan(text: value, style: const TextStyle(color: Colors.black87)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.themeMode == ThemeMode.dark
        ? themeProvider.darkTheme
        : themeProvider.lightTheme;

    final colorScheme = theme.colorScheme;
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Konfirmasi Pemesanan", style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      buildInfoRow(Icons.person, "Nama Pemilik", ownerName, colorScheme.primary),
                      buildInfoRow(Icons.phone, "Nomor HP", ownerPhone, colorScheme.primary),
                      const SizedBox(height: 12),
                      buildInfoRow(Icons.pets, "Nama Hewan", petName, colorScheme.secondary),
                      buildInfoRow(Icons.cake, "Usia Hewan", "$petAge tahun", colorScheme.secondary),
                      buildInfoRow(Icons.info_outline, "Ras Hewan", petBreed ?? 'Tidak ada', colorScheme.secondary),
                      const SizedBox(height: 12),
                      buildInfoRow(Icons.date_range, "Tanggal", formattedDate, colorScheme.tertiary),
                      buildInfoRow(Icons.schedule, "Jadwal", selectedSchedule, colorScheme.tertiary),
                      buildInfoRow(Icons.medical_services, "Layanan", selectedService, colorScheme.tertiary),
                      buildInfoRow(Icons.person_pin, "Dokter Jaga", "Dr. $doctorOnDuty", colorScheme.tertiary),
                      const SizedBox(height: 12),
                      buildInfoRow(Icons.attach_money, "Harga Layanan", "Rp ${servicePrice.toStringAsFixed(2)}", colorScheme.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Konfirmasi Pemesanan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid == null) return;

                    try {
                      final firestore = FirebaseFirestore.instance;

                      final bookingRef = await firestore.collection('bookings').add({
                        'userId': uid,
                        'ownerName': ownerName,
                        'ownerPhone': ownerPhone,
                        'petName': petName,
                        'petAge': petAge,
                        'petBreed': petBreed,
                        'selectedSchedule': selectedSchedule,
                        'selectedDate': selectedDate.toIso8601String(),
                        'selectedService': selectedService,
                        'doctorOnDuty': doctorOnDuty,
                        'servicePrice': servicePrice,
                        'status': 'booked',
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      final reminderRef = firestore
                          .collection('users')
                          .doc(uid)
                          .collection('reminders')
                          .doc();

                      await reminderRef.set({
                        'title': 'Janji temu $selectedService untuk $petName dengan Dr. $doctorOnDuty',
                        'date': selectedDate.toIso8601String(),
                        'bookingId': bookingRef.id,
                        'isCompleted': false,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pemesanan dan pengingat berhasil dibuat!")),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Terjadi kesalahan: $e")),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
