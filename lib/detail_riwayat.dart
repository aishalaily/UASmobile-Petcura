import 'package:flutter/material.dart';

class DetailMedicalRecordPage extends StatelessWidget {
  final Map<String, dynamic> record;

  const DetailMedicalRecordPage(this.record, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Detail Riwayat',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color ?? theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record["title"] ?? "-",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color ?? theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Dokter: ${record["doctor"] ?? "-"}",
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color ?? theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tanggal: ${record["date"] ?? "-"}",
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color ?? theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Deskripsi Layanan:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color ?? theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              record["description"] ??
                  "Informasi lebih lanjut tentang layanan ini dapat ditemukan di dalam aplikasi. "
                  "Silakan hubungi klinik untuk pertanyaan lebih lanjut.",
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color ?? theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
