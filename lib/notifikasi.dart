import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notifikasi extends StatefulWidget {
  const Notifikasi({Key? key}) : super(key: key);

  @override
  State<Notifikasi> createState() => _NotifikasiState();
}

class _NotifikasiState extends State<Notifikasi> {
  String selectedCategory = 'Reminder';
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReminders();
  }

  Future<void> fetchReminders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .get();

    setState(() {
      notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // simpan ID untuk penghapusan
        return data;
      }).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor = isDark ? Colors.brown[200] : const Color(0xFF6D4C41);
    final unselectedColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifikasi',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: buildCategoryCard("Reminder", "Pengingat", selectedColor, unselectedColor)),
                const SizedBox(width: 12),
                Expanded(child: buildCategoryCard("Info", "Umum", selectedColor, unselectedColor)),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedCategory == 'Reminder'
                    ? buildReminderList(notifications, isDark)
                    : Center(
                        child: Text(
                          "Tidak ada notifikasi umum.",
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget buildReminderList(List<Map<String, dynamic>> reminders, bool isDark) {
    if (reminders.isEmpty) {
      return Center(
        child: Text(
          "Tidak ada pengingat saat ini.",
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: reminders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        final dateTime = DateTime.tryParse(reminder['date'] ?? '');
        final formattedDate = dateTime != null
            ? "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}"
            : 'Waktu tidak tersedia';

        return Dismissible(
          key: Key(reminder['id']),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) async {
            setState(() => notifications.removeAt(index));
            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid != null) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('reminders')
                  .doc(reminder['id'])
                  .delete();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Pengingat dihapus")),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : const Color(0xFFF8F3EE),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder['title'] ?? 'Judul tidak tersedia',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    formattedDate,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCategoryCard(String category, String label, Color? selectedColor, Color? unselectedColor) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor!.withOpacity(0.15) : Colors.transparent,
          border: Border.all(color: isSelected ? selectedColor! : unselectedColor!),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? selectedColor : unselectedColor,
          ),
        ),
      ),
    );
  }
}
