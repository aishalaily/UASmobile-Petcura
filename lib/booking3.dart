import 'package:flutter/material.dart';
import 'package:utsuas/home.dart';
import 'package:utsuas/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Tambahkan package intl untuk formatting tanggal

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
  final DateTime selectedDate; // Tambahkan parameter selectedDate

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
    required this.selectedDate, // wajib
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.themeMode == ThemeMode.dark
        ? themeProvider.darkTheme
        : themeProvider.lightTheme;

    final colorScheme = theme.colorScheme;

    // Format tanggal yang dipilih agar tampil user-friendly
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
        title: Text("Konfirmasi Pemesanan", style: TextStyle(color: colorScheme.onPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informasi Pemilik
              Text("Nama Pemilik: $ownerName", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
              Text("Nomor HP: $ownerPhone", style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),

              // Informasi Hewan
              Text("Nama Hewan: $petName", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
              Text("Usia Hewan: $petAge tahun", style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
              Text("Ras Hewan: ${petBreed ?? 'Tidak ada'}", style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),

              // Informasi Layanan
              Text("Tanggal: $formattedDate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
              Text("Jadwal: $selectedSchedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
              Text("Layanan: $selectedService", style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
              Text("Dokter Jaga: Dr. $doctorOnDuty", style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),

              // Informasi Harga Layanan
              Text("Harga Layanan: Rp ${servicePrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
              const SizedBox(height: 24),

              // Button Konfirmasi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid == null) return;

                    try {
                      final firestore = FirebaseFirestore.instance;

                      // Simpan data booking ke koleksi 'bookings'
                      final bookingRef = await firestore.collection('bookings').add({
                        'userId': uid,
                        'ownerName': ownerName,
                        'ownerPhone': ownerPhone,
                        'petName': petName,
                        'petAge': petAge,
                        'petBreed': petBreed,
                        'selectedSchedule': selectedSchedule,
                        'selectedDate': selectedDate.toIso8601String(), // Simpan tanggal juga
                        'selectedService': selectedService,
                        'doctorOnDuty': doctorOnDuty,
                        'servicePrice': servicePrice,
                        'status': 'booked',
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      // Tambahkan reminder di users/{userId}/reminders
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

                  child: Text(
                    "Konfirmasi Pemesanan",
                    style: TextStyle(color: colorScheme.onPrimary, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
