import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:utsuas/booking1.dart';

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
  LatLng? clinicLocation;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    fetchClinicData();
  }

  Future<void> fetchClinicData() async {
    try {
      var clinicDoc = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .get();

      var servicesSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .collection('services')
          .get();

      var doctorsSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .collection('doctors')
          .get();

      final data = clinicDoc.data() as Map<String, dynamic>;
      double lat = data['latitude'] ?? 0.0;
      double lng = data['longitude'] ?? 0.0;

      setState(() {
        clinicData = clinicDoc;
        services = servicesSnapshot.docs;
        doctors = doctorsSnapshot.docs;
        clinicLocation = LatLng(lat, lng);
        isLoading = false;
      });
    } catch (e) {
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
    final limitedDoctors = doctors.take(3).toList();

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
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  clinic['image_url'] ?? 'https://via.placeholder.com/400x200',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Gagal memuat gambar');
                  },
                ),
              ),
              const SizedBox(height: 20),
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
              if (clinicLocation != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Lokasi Klinik',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.brown,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: clinicLocation!,
                        zoom: 16,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('clinic'),
                          position: clinicLocation!,
                          infoWindow: InfoWindow(title: clinic['name']),
                        ),
                      },
                      onMapCreated: (controller) {
                        mapController = controller;
                      },
                      myLocationEnabled: false,
                      zoomControlsEnabled: false,
                      liteModeEnabled: true,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.access_time, size: 20, color: Colors.brown),
                  const SizedBox(width: 8),
                  const Text('Jam Operasional', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  Text(
                    clinic['Status'] ?? 'Buka',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${clinic['openTime'] ?? '-'} - ${clinic['closeTime'] ?? '-'}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Divider(),

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
                  final name = service['name'] ?? '';
                  final iconData = getIconFromServiceName(name);
                  return serviceItem(iconData, name, isDarkMode);
                },
              ),
              const SizedBox(height: 20),

              Text(
                'Dokter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.brown),
              ),
              const SizedBox(height: 12),
              ...limitedDoctors.map((doc) {
                final doctor = doc.data() as Map<String, dynamic>;
                return doctorItem(doctor['name'] ?? 'No Name', doctor['photoURL'] ?? '', isDarkMode);
              }).toList(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllDoctorsPage(clinicId: widget.clinicId, doctors: doctors),
                      ),
                    );
                  },
                  child: const Text('Lihat Semua', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BookingPage()),
              );
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

  IconData getIconFromServiceName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('vaksin')) return Icons.vaccines;
    if (lower.contains('konsultasi')) return Icons.chat;
    if (lower.contains('steril')) return Icons.pets;
    if (lower.contains('check') || lower.contains('periksa')) return Icons.monitor_heart;
    if (lower.contains('darurat')) return Icons.emergency;
    if (lower.contains('operasi')) return Icons.health_and_safety;
    return Icons.miscellaneous_services;
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
            Icon(icon, color: Colors.red),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget doctorItem(String name, String photoURL, bool isDarkMode) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey[300],
        child: photoURL.isEmpty
            ? Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.grey)
            : null,
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

class AllDoctorsPage extends StatelessWidget {
  final String clinicId;
  final List<DocumentSnapshot> doctors;

  const AllDoctorsPage({Key? key, required this.clinicId, required this.doctors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Semua Dokter"),
        backgroundColor: isDarkMode ? Colors.black : Colors.brown,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index].data() as Map<String, dynamic>;
          final photoURL = doctor['photoURL'] ?? '';

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey[300],
              child: photoURL.isEmpty
                  ? Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.grey)
                  : null,
            ),
            title: Text(
              doctor['name'] ?? 'No Name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Row(
              children: const [
                Icon(Icons.star, color: Colors.orange, size: 16),
                SizedBox(width: 4),
                Text('4.5'),
              ],
            ),
          );
        },
      ),
    );
  }
}
