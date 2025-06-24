import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const BookingDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy').format(DateTime.parse(data['selectedDate']));

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Booking")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _infoTile("Nama Hewan", data['petName']),
            _infoTile("Jenis Layanan", data['selectedService']),
            _infoTile("Dokter", "Dr. ${data['doctorOnDuty']}"),
            _infoTile("Tanggal", date),
            _infoTile("Jadwal", data['selectedSchedule']),
            _infoTile("Status", data['status']),
            _infoTile("Harga", "Rp ${data['servicePrice'].toString()}"),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String? value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value ?? '-', style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
}
