import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:utsuas/booking2.dart';
import 'package:utsuas/setting.dart';
import 'package:utsuas/booking1.dart';
import 'package:utsuas/notifikasi.dart';
import 'package:utsuas/profil.dart';
import 'package:utsuas/riwayat_medis.dart';
import 'package:utsuas/rs_profil.dart';
import 'package:utsuas/home.dart';
import 'package:utsuas/theme_provider.dart';
import 'package:provider/provider.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final Color primaryColor = const Color(0xFFD1B195);
  DateTime selectedDate = DateTime.now();
  String selectedService = "";
  String selectedTime = "";

  final Map<String, double> servicePrices = {
    "Vaksin": 250000.0,
    "Check-up": 100000.0,
    "Sterilisasi": 500000.0,
    "Konsultasi Kesehatan": 200000.0,
    "Operasi Ringan": 750000.0,
    "Layanan Darurat": 1000000.0,
  };

   final Map<String, Map<String, String>> clinicSchedule = {
    "08:30 am": {
      "Senin": "Prof. Dr. I. Komang Wiarsa Sardjana, drh.",
      "Selasa": "Prof. Dr. Wiwik Misaco Yuniarti, drh., M.Kes.",
      "Rabu": "Lianny Nangoi, drh., M.Kes.",
      "Kamis": "Dr. Nusdianto Triakoso, drh., M.P.",
      "Jumat": "Dr. Boedi Setiawan, drh., M.P.",
    },
    "01:00 pm": {
      "Senin": "Drh. Lina Susanti, MS., Ph.D.",
      "Kamis": "Drh. Mirza Atikah Madarina Hisyam, M.Si.",
      "Jumat": "Drh. Mirza Atikah Madarina Hisyam, M.Si.",
    },
    "03:00 pm": {
      "Selasa": "Simeon Marcellino Tantono, drh.",
      "Kamis": "Puruh Renzy Amdalia, drh.",
      "Jumat": "Puruh Renzy Amdalia, drh.",
    },
    "06:00 pm": {
      "Senin": "Dr. Dony Chrismanto, drh., MS.",
      "Selasa": "Dr. Dony Chrismanto, drh., M.S.",
      "Rabu": "Dr. Dony Chrismanto, drh., M.S.",
      "Jumat": "Dr. Dony Chrismanto, drh., M.S.",
    },
    "11:00 pm": {
      "Senin": "Simeon Marcellino Tantono, drh.",
      "Selasa": "Puruh Renzy Amdalia, drh.",
      "Rabu": "Puruh Renzy Amdalia, drh.",
      "Kamis": "Abihilal Zikra Taim, drh.",
      "Jumat": "Abihilal Zikra Taim, drh.",
    },
  };

  List<String> get availableTimes => clinicSchedule.keys.toList();

  String getDayName(DateTime date) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[date.weekday - 1];
  }

  String getDoctor() {
    final day = getDayName(selectedDate);
    return clinicSchedule[selectedTime]?.containsKey(day) == true
        ? clinicSchedule[selectedTime]![day]!
        : "Tidak ada dokter tersedia";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isLightMode = theme.themeMode == ThemeMode.light;

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isLightMode ? Colors.white : Colors.black,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isLightMode ? Colors.black : Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Booking", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("RS Medika Sejahtera",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  stepItem("1", "Booking Jadwal", active: true, isLightMode: isLightMode),
                  stepItem("2", "Konfirmasi", isLightMode: isLightMode),
                  stepItem("3", "Konfirmasi", isLightMode: isLightMode),
                ],
              ),
              const SizedBox(height: 24),

              Text("Pilih Layanan",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedService.isNotEmpty ? selectedService : null,
                hint: Text("Pilih Layanan", style: TextStyle(color: textColor)),
                dropdownColor: bgColor,
                items: servicePrices.keys.map((service) {
                  return DropdownMenuItem(
                    value: service,
                    child: Text(service, style: TextStyle(color: textColor)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedService = value!;
                    selectedTime = "";
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isLightMode ? const Color(0xFFF5F5F5) : Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              const SizedBox(height: 12),
              if (selectedService.isNotEmpty)
                Text(
                  "Harga: Rp ${servicePrices[selectedService]!.toStringAsFixed(0)}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                ),
              const SizedBox(height: 24),
              Text("Pilih Tanggal",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              const SizedBox(height: 12),
              CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                onDateChanged: (newDate) {
                  setState(() {
                    selectedDate = newDate;
                    selectedTime = "";
                  });
                },
              ),
              const SizedBox(height: 24),

              Text("Pilih Jam",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.5,
                children: availableTimes.map((time) {
                  bool isSelected = time == selectedTime;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTime = time;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : isLightMode
                                ? const Color(0xFFF5F5F5)
                                : Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? primaryColor : (isLightMode ? Colors.grey.shade300 : Colors.grey.shade600),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              if (selectedService.isNotEmpty && selectedTime.isNotEmpty)
                Text(
                  "Dokter Jaga: ${getDoctor()}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (selectedService.isEmpty || selectedTime.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Silakan lengkapi data terlebih dahulu.")),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Booking2Page(
                          selectedSchedule: selectedTime,
                          selectedService: selectedService,
                          doctorOnDuty: getDoctor(),
                          servicePrice: servicePrices[selectedService]!,
                          selectedDate: selectedDate,  // kirim tanggal
                        ),
                      ),
                    );
                  },

                  child: const Text("Lanjutkan", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD0A67D),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()),
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
                MaterialPageRoute(builder: (context) => MedicalHistoryPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OwnerProfilePage()),
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

  Widget stepItem(String number, String label, {bool active = false, required bool isLightMode}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: active ? primaryColor : (isLightMode ? Colors.grey[300] : Colors.grey[600]),
          child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
              fontSize: 12,
              color: active ? Colors.grey[700] : Colors.grey[400],
            )),
      ],
    );
  }
}
