import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:utsuas/booking3.dart';
import 'package:utsuas/theme_provider.dart';
import 'package:provider/provider.dart';

class Booking2Page extends StatefulWidget {
  final String selectedSchedule;
  final String selectedService;
  final String doctorOnDuty;
  final double servicePrice;
  final DateTime selectedDate;

  const Booking2Page({
    Key? key,
    required this.selectedSchedule,
    required this.selectedService,
    required this.doctorOnDuty,
    required this.servicePrice,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<Booking2Page> createState() => _Booking2PageState();
}

class _Booking2PageState extends State<Booking2Page> {
  String? selectedPetId;
  Map<String, dynamic>? selectedPetData;
  String ownerName = '';
  String ownerPhone = '';

  Future<void> fetchUserAndPets() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final petCollection = await FirebaseFirestore.instance.collection('users').doc(uid).collection('pets').get();

    if (userDoc.exists) {
      setState(() {
        ownerName = userDoc['name'] ?? '';
        final phones = userDoc['phoneNumbers'] as List<dynamic>?;
        ownerPhone = (phones != null && phones.isNotEmpty) ? phones[0].toString() : '';
      });
    }


    if (petCollection.docs.isNotEmpty) {
      setState(() {
        selectedPetId = petCollection.docs.first.id;
        selectedPetData = petCollection.docs.first.data();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserAndPets();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.themeMode == ThemeMode.dark
        ? themeProvider.darkTheme
        : themeProvider.lightTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        title: Text("Data Hewan", style: TextStyle(color: colorScheme.onPrimary)),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pilih Hewan:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('pets')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final pets = snapshot.data!.docs;
                return DropdownButton<String>(
                  value: selectedPetId,
                  isExpanded: true,
                  hint: Text("Pilih hewan peliharaan"),
                  items: pets.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(data['name'] ?? 'Tidak Bernama'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final pet = pets.firstWhere((doc) => doc.id == value);
                    setState(() {
                      selectedPetId = value;
                      selectedPetData = pet.data() as Map<String, dynamic>;
                    });
                  },
                );
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: selectedPetData != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmationPage(
                              ownerName: ownerName,
                              ownerPhone: ownerPhone,
                              petName: selectedPetData!['name'] ?? '',
                              petAge: selectedPetData!['age']?.toString() ?? '0',
                              petBreed: selectedPetData!['breed'],
                              selectedSchedule: widget.selectedSchedule,
                              selectedService: widget.selectedService,
                              doctorOnDuty: widget.doctorOnDuty,
                              servicePrice: widget.servicePrice,
                              selectedDate: widget.selectedDate,  // Ini penting supaya tanggalnya diteruskan
                            ),
                          ),
                        );

                      }
                    : null,
                child: Text("Lanjut", style: TextStyle(color: colorScheme.onPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
