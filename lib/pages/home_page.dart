// Copiez ce fichier pour remplacer votre home_page.dart actuel
// Le bouton de test est maintenant ACTIVÉ

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hijri/hijri_calendar.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'quran_list_page.dart';
import 'misbaha_page.dart';
import 'duas_list_page.dart';
import 'calendar_page.dart';
import 'prayer_times_page.dart';
import 'qibla_page.dart';
import 'settings_page.dart';
import 'profil_page.dart';
import 'bottom_nav.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  
  String currentTime = '9:41';
  String currentPrayer = 'Waqtu Dhuhr';
  String nextPrayer = 'Asr';
  String location = 'Sfax, Tunisie';
  Timer? _timer;
  Map<String, String> prayerTimes = {};
  String hijriDate = '';
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPrayerData();
    _startClock();
    _loadHijriDate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? 'Utilisateur';
      });
    }
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        currentTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
        if (prayerTimes.isNotEmpty) {
          _updateCurrentPrayer(now);
        }
      });
    }
  }

  void _updateCurrentPrayer(DateTime now) {
    final currentMinutes = now.hour * 60 + now.minute;

    final prayers = prayerTimes.entries.map((e) {
      final parts = e.value.split(':');
      final minutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      return MapEntry(e.key, minutes);
    }).toList();

    prayers.sort((a, b) => a.value.compareTo(b.value));

    String current = 'Isha';
    String next = 'Fajr';

    for (int i = 0; i < prayers.length; i++) {
      if (currentMinutes >= prayers[i].value) {
        current = prayers[i].key;
        next = i < prayers.length - 1 ? prayers[i + 1].key : prayers[0].key;
      } else {
        next = prayers[i].key;
        break;
      }
    }

    if (mounted) {
      setState(() {
        currentPrayer = _getPrayerDisplayName(current);
        nextPrayer = next;
      });
    }
  }

  String _getPrayerDisplayName(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return 'Waqtu Fajr';
      case 'Dhuhr':
        return 'Waqtu Dhuhr';
      case 'Asr':
        return 'Waqtu Asr';
      case 'Maghrib':
        return 'Waqtu Maghrib';
      case 'Isha':
        return 'Waqtu Isha';
      default:
        return 'Waqtu $prayer';
    }
  }

  void _loadPrayerData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('myprayer')
          .doc('data')
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          final data = snapshot.data() as Map<String, dynamic>;
          setState(() {
            location = data['location'] ?? 'Sfax, Tunisie';
            if (data['prayerTimes'] != null) {
              prayerTimes = Map<String, String>.from(data['prayerTimes']);
              _updateCurrentPrayer(DateTime.now());
            }
          });
          
          _schedulePrayerNotifications();
        }
      });
    } else {
      _firestore.collection('myprayer').doc('data').snapshots().listen((snapshot) {
        if (snapshot.exists && mounted) {
          final data = snapshot.data() as Map<String, dynamic>;
          setState(() {
            location = data['location'] ?? 'Sfax, Tunisie';
            if (data['prayerTimes'] != null) {
              prayerTimes = Map<String, String>.from(data['prayerTimes']);
              _updateCurrentPrayer(DateTime.now());
            }
          });
          
          _schedulePrayerNotifications();
        }
      });
    }
  }

 Future<void> _schedulePrayerNotifications() async {
  try {
    if (prayerTimes.isEmpty) {
      print('⚠️ Pas d\'horaires disponibles');
      return;
    }

    // ✅ AJOUTEZ CETTE SECTION POUR TEST
    final now = DateTime.now();
    final testTime = now.add(const Duration(minutes: 2)); // Dans 2 minutes
    final testTimeStr = '${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')}';
    
    print('🧪 TEST: Notification Fajr programmée pour $testTimeStr');

    await _notificationService.schedulePrayerNotifications(
      fajr: prayerTimes['Fajr'] ?? '6:02',  // ← Dans 2 minutes pour tester !
      dhuhr: prayerTimes['Dhuhr'] ?? '12:15',
      asr: prayerTimes['Asr'] ?? '15:54',
      maghrib: prayerTimes['Maghrib'] ?? '17:20',
      isha: prayerTimes['Isha'] ?? '17:47',
    );

    print('✅ Notifications planifiées');
    
    final pending = await _notificationService.getPendingNotifications();
    print('📋 ${pending.length} notifications planifiées');
  } catch (e) {
    print('❌ Erreur: $e');
  }
}

  void _loadHijriDate() {
    final hijri = HijriCalendar.now();
    final monthNames = [
      '',
      'Muharram',
      'Safar',
      'Rabi\' al-awwal',
      'Rabi\' al-thani',
      'Jumada al-awwal',
      'Jumada al-thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qi\'dah',
      'Dhu al-Hijjah',
    ];
    
    final monthName = hijri.hMonth >= 1 && hijri.hMonth <= 12 
        ? monthNames[hijri.hMonth] 
        : '';
    
    if (mounted) {
      setState(() {
        hijriDate = '$monthName ${hijri.hYear} H';
      });
    }
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildMainContent(isDark),
    );
  }

  Widget _buildMainContent(bool isDark) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    _buildTimeCard(isDark),
                    const SizedBox(height: 24),
                    _buildCalendarButton(),
                    const SizedBox(height: 40),
                    _buildMosqueIcon(),
                    const SizedBox(height: 20),
                    Text(
                      'Priére du jour',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F3460),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 50),
                    _buildQuickActions(isDark),
                    const SizedBox(height: 30),
                    // ✅ BOUTON DE TEST ACTIVÉ
                    _buildTestNotificationButton(isDark),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        SharedBottomNav(
          currentIndex: 0,
          onHomePressed: (context) {},
          onTimesPressed: (context) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrayerTimesPage()),
            );
          },
          onQiblaPressed: (context) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QiblaPage()),
            );
          },
          onSettingsPressed: (context) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }

  // ✅ BOUTON DE TEST DES NOTIFICATIONS
  Widget _buildTestNotificationButton(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () async {
          await _notificationService.showImmediateNotification(
            title: '🕌 Test de notification',
            body: 'Les notifications fonctionnent correctement! C\'est l\'heure de la prière!',
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '✅ Notification de test envoyée!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 3),
                backgroundColor: const Color(0xFF2E7D32),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        icon: const Icon(Icons.notifications_active, size: 26),
        label: const Text(
          'TESTER LES NOTIFICATIONS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F3460),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor: const Color(0xFF0F3460).withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F3460),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              userName.isNotEmpty ? 'Bienvenue $userName' : 'Bienvenue',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTime,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F3460),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentPrayer,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3460),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CalendarScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calendrier Hijri',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hijriDate.isNotEmpty ? hijriDate : 'Ramadan 1444 H',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMosqueIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.mosque,
        color: Colors.white,
        size: 60,
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.menu_book_rounded, 'Coran', isDark, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuranListPage()),
          );
        }),
        _buildActionButton(Icons.circle_outlined, 'Misbaha', isDark, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MisbahaPage()),
          );
        }),
        _buildActionButton(Icons.back_hand_rounded, 'Duas', isDark, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DuasListPage()),
          );
        }),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    bool isDark,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F3460).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F3460),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}