import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:utsuas/booking1.dart';
import 'package:utsuas/profil.dart';
import 'package:utsuas/riwayat_medis.dart';
import 'package:utsuas/setting.dart';
import 'package:utsuas/rs_profil.dart';
import 'package:utsuas/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isLightMode = theme.themeMode == ThemeMode.light;

    // Referensi dokumen rshp_unair
    final DocumentReference clinicRef = FirebaseFirestore.instance.collection('clinics').doc('rshp_unair');

    return Scaffold(
      backgroundColor: isLightMode ? Colors.white : Colors.black,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: isLightMode ? Colors.white : Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.pets, color: isLightMode ? Color(0xFFD0A67D) : Colors.white),
            SizedBox(width: 10),
            const Text(
              'PETCURA',
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.settings, color: isLightMode ? Color(0xFF6D4C41) : Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar (bisa ditambah fungsi nanti)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isLightMode ? Colors.grey.shade200 : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search...",
                  icon: Icon(Icons.search),
                ),
              ),
            ),

            // Banner Slider (static dulu)
            const _BannerSlider(),
            const SizedBox(height: 20),

            // Bagian data RSHP Unair dari Firestore
            FutureBuilder<DocumentSnapshot>(
              future: clinicRef.get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text('Data klinik tidak ditemukan');
                }

                final clinicData = snapshot.data!.data() as Map<String, dynamic>;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isLightMode ? Color(0xFFF9F4F1) : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar RS
                      if (clinicData['imageUrl'] != null && clinicData['imageUrl'].isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            clinicData['imageUrl'],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                      const SizedBox(height: 12),

                      Text(
                        clinicData['name'] ?? 'RS Hewan',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(clinicData['address'] ?? '-'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 18, color: Colors.brown),
                          const SizedBox(width: 6),
                          Text(clinicData['phone'] ?? '-'),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 18, color: Colors.brown),
                          const SizedBox(width: 6),
                          Text('Jam Operasional: '),
                          Text(
                            '${clinicData['openTime'] ?? '-'} - ${clinicData['closeTime'] ?? '-'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            clinicData['status'] ?? 'Buka',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: clinicData['status'] == 'Buka' ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ClinicProfilePage(clinicId: 'rshp_unair')),
                            );
                          },
                          child: const Text('View Profile'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            // Bisa lanjut section lain disini, misalnya berita, reminder, dll.
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD0A67D),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BookingPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MedicalHistoryPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OwnerProfilePage()),
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


class _BannerSlider extends StatefulWidget {
  const _BannerSlider({super.key});

  @override
  State<_BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<_BannerSlider> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> _imageUrls = [
    'https://i.pinimg.com/736x/09/b6/a3/09b6a3bad33769252442474788338637.jpg',
    'https://d1csarkz8obe9u.cloudfront.net/posterpreviews/veterinary-hospital-advert-design-template-97e0360ce0df3851d2a9a54d6f66ced7_screen.jpg?ts=1698373242',
    'https://d1csarkz8obe9u.cloudfront.net/posterpreviews/dog-clinic-flyer-design-template-d0dcd2d5f80b4d082160798f94b0690a_screen.jpg?ts=1644976348',
    'https://img.freepik.com/free-vector/flat-design-animal-sterilization-template_23-2150059352.jpg?t=st=1745394510~exp=1745398110~hmac=7c0bca5e2522bae7b6b2192955aa824c4806db0317a1ec63037edbc4cee191fe&w=1380',
    'https://img.freepik.com/vector-gratis/cartel-servicio-cuidado-mascotas-dinamico-dibujado-mano_23-2149636393.jpg?t=st=1745394559~exp=1745398159~hmac=e10dd38893e4534008ae1bb6057c91fe0fc92c915697d9043bde6114fa4a9085&w=1380',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), _autoSlide);
  }

  void _autoSlide() {
    if (_controller.hasClients) {
      int nextPage = _currentPage + 1;
      if (nextPage >= _imageUrls.length) nextPage = 0;

      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      setState(() {
        _currentPage = nextPage;
      });

      Future.delayed(const Duration(seconds: 4), _autoSlide);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _controller,
        itemCount: _imageUrls.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _imageUrls[index],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          );
        },
      ),
    );
  }
}
