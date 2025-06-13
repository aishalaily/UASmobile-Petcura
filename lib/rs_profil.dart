import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicProfilePage extends StatefulWidget {
  final String clinicId;

  const ClinicProfilePage({Key? key, required this.clinicId}) : super(key: key);

  @override
  _ClinicProfilePageState createState() => _ClinicProfilePageState();
}

class _ClinicProfilePageState extends State<ClinicProfilePage> {
  late DocumentSnapshot clinicData;
  List<DocumentSnapshot> services = [];
  List<DocumentSnapshot> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClinicData();
  }

  Future<void> fetchClinicData() async {
    try {
      // Ambil data klinik
      var clinicDoc = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .get();

      // Ambil services subcollection
      var servicesSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .collection('services')
          .get();

      // Ambil doctors subcollection
      var doctorsSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .collection('doctors')
          .get();

      setState(() {
        clinicData = clinicDoc;
        services = servicesSnapshot.docs;
        doctors = doctorsSnapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      print("Error fetching clinic data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!clinicData.exists) {
      return const Scaffold(
        body: Center(child: Text('Clinic not found')),
      );
    }

    final clinic = clinicData.data() as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image from clinic data
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  clinic['imageUrl'] ?? 'https://via.placeholder.com/400x200',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              // Clinic Info
              Text(
                clinic['name'] ?? 'No Name',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 20, color: isDarkMode ? Colors.white : Colors.brown),
                  const SizedBox(width: 8),
                  Text(clinic['phone'] ?? '-', style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: isDarkMode ? Colors.white : Colors.brown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      clinic['address'] ?? '-',
                      style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Operational Hours
              Row(
                children: [
                  Icon(Icons.access_time, size: 20, color: Colors.brown),
                  const SizedBox(width: 8),
                  const Text('Jam Operasional', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  Text(
                    'Buka',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                clinic['openTime'] ?? '-',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Divider(),

              // Services (dari Firebase)
              Text(
                'Layanan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.brown),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3.5,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index].data() as Map<String, dynamic>;
                  final iconData = getIconFromString(service['icon']);
                  return serviceItem(iconData, service['name'] ?? 'No Name', isDarkMode);
                },
              ),
              const SizedBox(height: 20),

              // Doctors (dari Firebase)
              Text(
                'Dokter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.brown),
              ),
              const SizedBox(height: 12),
              ...doctors.map((doc) {
                final doctor = doc.data() as Map<String, dynamic>;
                return doctorItem(doctor['name'] ?? 'No Name', isDarkMode);
              }).toList(),
              const SizedBox(height: 20),

              const Divider(),

              // Location section tetap static atau bisa diubah dinamis jika ada data latitude/longitude
              Text(
                'Lokasi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.brown),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://maps.googleapis.com/maps/api/staticmap?center=-6.1754,106.8272&zoom=15&size=600x300&markers=color:red%7Clabel:H%7C-6.1754,106.8272&key=YOUR_API_KEY',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9B18E),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              // Navigasi ke halaman booking (bisa kirim clinicId jika perlu)
            },
            child: const Text(
              'Booking',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk mapping string icon name ke IconData Flutter
  IconData getIconFromString(String? iconName) {
    switch (iconName) {
      case 'vaccines':
        return Icons.vaccines;
      case 'medical_services':
        return Icons.medical_services;
      case 'favorite':
        return Icons.favorite;
      case 'add':
        return Icons.add;
      default:
        return Icons.miscellaneous_services;
    }
  }

  Widget serviceItem(IconData icon, String title, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade700 : const Color(0xFFF7F1EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDarkMode ? Colors.white : Colors.brown),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget doctorItem(String name, bool isDarkMode) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey[300],
        child: Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.grey),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
      subtitle: Row(
        children: const [
          Icon(Icons.star, color: Colors.orange, size: 16),
          SizedBox(width: 4),
          Text('4.5'),
        ],
      ),
    );
  }
}
