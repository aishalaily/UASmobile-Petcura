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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utsuas/detail_artikel.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isLightMode = theme.themeMode == ThemeMode.light;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final clinicRef = FirebaseFirestore.instance.collection('clinics').doc('rshp_unair');

    final List<Map<String, String>> edukasiList = [
    {
      'title': 'Cara Merawat Anjing Saat Musim Hujan',
      'imageUrl': 'https://i.pinimg.com/736x/ff/01/33/ff013304925299204f57d9ee0ca6ee98.jpg',
      'content':
          'Saat musim hujan, jaga anjing Anda tetap kering dan hangat. Gunakan jas hujan khusus hewan untuk melindungi dari air dan dingin. Hindari berjalan di genangan air karena bisa membawa penyakit seperti leptospirosis. Setelah berjalan-jalan, segera keringkan bulunya, terutama bagian telapak kaki dan perut. Pastikan tempat tidurnya tetap kering dan hangat untuk mencegah flu atau infeksi kulit.'
    },
    {
      'title': 'Tips Memandikan Kucing yang Takut Air',
      'imageUrl': 'https://i.pinimg.com/736x/ca/55/c6/ca55c66da5ef1f1e06b47e4350c02553.jpg',
      'content':
          'Memandikan kucing yang takut air memerlukan kesabaran. Gunakan air hangat dan suara lembut untuk membuatnya merasa tenang. Mandikan di bak kecil atau wastafel, bukan pancuran. Gunakan sampo khusus kucing dan hindari wajah. Jika terlalu takut, gunakan lap basah atau dry shampoo sebagai alternatif. Pastikan ruangan hangat dan keringkan bulu dengan handuk lembut secara perlahan.'
    },
    {
      'title': 'Vaksin Penting untuk Hewan Peliharaan',
      'imageUrl': 'https://i.pinimg.com/736x/81/9c/21/819c21993589d5755e1899eb57ae934f.jpg',
      'content':
          'Vaksinasi adalah perlindungan utama bagi hewan peliharaan dari penyakit serius seperti rabies, parvovirus, distemper, dan leptospirosis. Anak anjing dan kucing memerlukan rangkaian vaksin sejak usia 6–8 minggu. Vaksinasi rutin membantu memperkuat sistem kekebalan tubuh dan mencegah penyebaran penyakit. Konsultasikan dengan dokter hewan untuk membuat jadwal vaksin yang sesuai dengan jenis dan usia hewan Anda.'
    },
  ];
 
    PageController edukasiController = PageController();
    int currentArticle = 0;

    return Scaffold(
      backgroundColor: isLightMode ? Colors.white : Colors.black,
      appBar: AppBar(
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userId != null)
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('reminders')
                    .orderBy('date')
                    .limit(1)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return SizedBox();
                  final reminder = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.alarm, color: Colors.orange),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text("Reminder: ${reminder['title']} - ${reminder['date']}"),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const _BannerSlider(),
            const SizedBox(height: 20),

            FutureBuilder<DocumentSnapshot>(
              future: clinicRef.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                if (!snapshot.hasData || !snapshot.data!.exists) return const Text('Data klinik tidak ditemukan');
                final data = snapshot.data!.data() as Map<String, dynamic>;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isLightMode ? Color(0xFFF9F4F1) : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data['imageUrl'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(data['imageUrl'], height: 180, width: double.infinity, fit: BoxFit.cover),
                        ),
                      SizedBox(height: 12),
                      Text(data['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text(data['address'] ?? ''),
                      SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.phone, size: 18, color: Colors.brown),
                        SizedBox(width: 6),
                        Text(data['phone'] ?? '-'),
                      ]),
                      SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.access_time, size: 18, color: Colors.brown),
                        SizedBox(width: 6),
                        Text("Jam Operasional: "),
                        Text('${data['openTime']} - ${data['closeTime']}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(data['status'] ?? 'Buka',
                            style: TextStyle(
                                color: data['status'] == 'Buka' ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ClinicProfilePage(clinicId: 'rshp_unair')),
                            );
                          },
                          child: const Text('View Profile'),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            Text("Artikel Edukasi", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: edukasiController,
                itemCount: edukasiList.length,
                itemBuilder: (context, index) {
                  final artikel = edukasiList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArticleDetailPage(
                            title: artikel['title']!,
                            imageUrl: artikel['imageUrl']!,
                            content: artikel['content']!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isLightMode ? Colors.white : Colors.grey.shade700,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              artikel['imageUrl']!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              artikel['title']!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => edukasiController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () => edukasiController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn),
                ),
              ],
            ),

            const SizedBox(height: 20),
            if (userId != null)
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('pets')
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                  final pets = snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hewan Peliharaan", style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: pets.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isLightMode ? Colors.white : Colors.grey.shade700,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.pets, size: 40, color: Color(0xFFD0A67D)),
                                  SizedBox(height: 6),
                                  Text(data['name'] ?? '-', style: TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  );
                },
              ),
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
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingPage()));
              break;
            case 2:
              if (userId != null) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MedicalHistoryPage(userId: userId)));
              }
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OwnerProfilePage()));
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
    'https://img.freepik.com/free-vector/flat-design-animal-sterilization-template_23-2150059352.jpg',
    'https://img.freepik.com/vector-gratis/cartel-servicio-cuidado-mascotas-dinamico-dibujado-mano_23-2149636393.jpg',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), _autoSlide);
  }

  void _autoSlide() {
    if (_controller.hasClients) {
      int nextPage = (_currentPage + 1) % _imageUrls.length;
      _controller.animateToPage(nextPage, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
      setState(() => _currentPage = nextPage);
      Future.delayed(Duration(seconds: 4), _autoSlide);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _controller,
        itemCount: _imageUrls.length,
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
