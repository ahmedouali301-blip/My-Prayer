import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'bottom_nav.dart';
import 'home_page.dart';
import 'qibla_page.dart';
import 'settings_page.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({Key? key}) : super(key: key);

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String nextPrayer = 'Dhuhr';
  String nextPrayerTime = '12:32';
  String timeRemaining = '2h.51m';
  Map<String, String> prayerTimes = {
    'Fajr': '05:20',
    'Chourouq': '06:40',
    'Dhuhr': '12:32',
    'Asr': '15:45',
    'Maghreb': '17:20',
    'Isha': '18:40',
  };
  
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadPrayerData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _updateNextPrayer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateNextPrayer();
    });
  }

  void _loadPrayerData() {
    _firestore
        .collection('myprayer')
        .doc('data')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          if (data['prayerTimes'] != null) {
            final firestoreTimes = Map<String, String>.from(data['prayerTimes']);
            
            prayerTimes = {
              'Fajr': firestoreTimes['Fajr'] ?? '05:20',
              'Chourouq': firestoreTimes['Chourouq'] ?? firestoreTimes['Sunrise'] ?? '06:40',
              'Dhuhr': firestoreTimes['Dhuhr'] ?? '12:32',
              'Asr': firestoreTimes['Asr'] ?? '15:45',
              'Maghreb': firestoreTimes['Maghrib'] ?? firestoreTimes['Maghreb'] ?? '17:20',
              'Isha': firestoreTimes['Isha'] ?? '18:40',
            };
            _updateNextPrayer();
          }
        });
      }
    });
  }

  void _updateNextPrayer() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    String? foundNextPrayer;
    String? foundNextTime;
    int? nextPrayerMinutes;

    for (var entry in prayerTimes.entries) {
      if (entry.key == 'Chourouq') continue;
      
      final parts = entry.value.split(':');
      final prayerMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);

      if (prayerMinutes > currentMinutes) {
        foundNextPrayer = entry.key;
        foundNextTime = entry.value;
        nextPrayerMinutes = prayerMinutes;
        break;
      }
    }

    if (foundNextPrayer == null) {
      foundNextPrayer = 'Fajr';
      foundNextTime = prayerTimes['Fajr'];
      final parts = foundNextTime!.split(':');
      nextPrayerMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]) + (24 * 60);
    }

    final remainingMinutes = nextPrayerMinutes! - currentMinutes;
    final hours = remainingMinutes ~/ 60;
    final minutes = remainingMinutes % 60;

    setState(() {
      nextPrayer = foundNextPrayer!;
      nextPrayerTime = foundNextTime!;
      timeRemaining = '${hours}h.${minutes}m';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildNextPrayerCard(isDark),
                  _buildPrayerTimesList(isDark),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SharedBottomNav(
            currentIndex: 1,
            onHomePressed: (context) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
            onTimesPressed: (context) {},
            onQiblaPressed: (context) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const QiblaPage()),
              );
            },
            onSettingsPressed: (context) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1B4965),
      ),
      child: const Center(
        child: Text(
          'Prochaine Priére',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Prochaine Priére',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$nextPrayer - $nextPrayerTime',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4965),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Dans $timeRemaining',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey[400] : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: prayerTimes.entries.map((entry) {
          final isNext = entry.key == nextPrayer && entry.key != 'Chourouq';
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                    color: isNext 
                      ? const Color(0xFF1B4965) 
                      : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                    color: isNext 
                      ? const Color(0xFF1B4965) 
                      : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}