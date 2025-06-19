import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingNotificationPage extends StatelessWidget {
  const BookingNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingsRef = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Booking'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada notifikasi booking."));
          }

          final bookings = snapshot.data!.docs.where((doc) {
            final status = doc['status'] ?? '';
            return status == 'booked';
          }).toList();

          if (bookings.isEmpty) {
            return const Center(child: Text("Tidak ada notifikasi aktif."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;

              final petName = data['petName'] ?? '-';
              final ownerName = data['ownerName'] ?? '-';
              final doctor = data['doctorOnDuty'] ?? '-';
              final dateStr = data['selectedDate'] ?? '';
              final schedule = data['selectedSchedule'] ?? '-';
              final service = data['selectedService'] ?? '-';
              final status = data['status'] ?? '-';

              String formattedDate = '-';
              try {
                final date = DateTime.parse(dateStr);
                formattedDate = DateFormat('dd/MM/yyyy').format(date);
              } catch (_) {}

              return Card(
                color: const Color(0xFFF1EFEF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.brown),
                  title: Text("🐾 Booking untuk $petName"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👤 Pemilik: $ownerName"),
                      Text("👨‍⚕️ Dokter: $doctor"),
                      Text("📅 Jadwal: $formattedDate, $schedule"),
                      Text("🔧 Layanan: $service"),
                      Text("📌 Status: $status"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
