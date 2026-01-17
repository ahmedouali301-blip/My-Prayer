import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'pages/auth_wrapper.dart';
import 'services/localization_service.dart';
import 'services/themes_service.dart';
import 'services/notification_service.dart';

// Initialize Firestore data function
Future<void> initializeFirestoreData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  await firestore.collection('myprayer').doc('data').set({
    'currentPrayer': 'Waqtu Dhuhr',
    'currentTime': '9.41',
    'location': 'Sfax, Tunisie',
    'prayerTimes': {
      'Fajr': '06:03',
      'Chourouq': '07:27',
      'Dhuhr': '12:30',
      'Asr': '15:15',
      'Maghrib': '17:35',
      'Isha': '19:05',
    }
  });
  
  print('Firestore data initialized successfully!');
}

Future<void> initializeAllSurahs() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  final List<Map<String, dynamic>> allSurahs = [
    {'name': 'Al-Fatiha', 'arabicName': 'الفاتحة', 'number': 1, 'verses': 7},
    {'name': 'Al-Fil', 'arabicName': 'الفيل', 'number': 105, 'verses': 5},
    {'name': 'Quraysh', 'arabicName': 'قريش', 'number': 106, 'verses': 4},
    {'name': 'Al-Maun', 'arabicName': 'الماعون', 'number': 107, 'verses': 7},
    {'name': 'Al-Kawthar', 'arabicName': 'الكوثر', 'number': 108, 'verses': 3},
    {'name': 'Al-Kafirun', 'arabicName': 'الكافرون', 'number': 109, 'verses': 6},
    {'name': 'An-Nasr', 'arabicName': 'النصر', 'number': 110, 'verses': 3},
    {'name': 'Al-Masad', 'arabicName': 'المسد', 'number': 111, 'verses': 5},
    {'name': 'Al-Ikhlas', 'arabicName': 'الإخلاص', 'number': 112, 'verses': 4},
    {'name': 'Al-Falaq', 'arabicName': 'الفلق', 'number': 113, 'verses': 5},
    {'name': 'An-Nas', 'arabicName': 'الناس', 'number': 114, 'verses': 6},
  ];
  
  for (var surah in allSurahs) {
    await firestore
        .collection('quran_surahs')
        .doc('surah_${surah['number']}')
        .set(surah);
  }
  
  print('All surahs initialized in Firestore!');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // UNCOMMENT TO INITIALIZE DATA (Run once, then comment again)
  //await initializeFirestoreData();
  // await initializeAllSurahs();
    // 🔔 Initialiser les notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalizationService _localizationService = LocalizationService();
  final ThemeService _themeService = ThemeService();
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
    _localizationService.addListener(_onLanguageChanged);
    _themeService.addListener(_onThemeChanged);
  }

  Future<void> _initializeServices() async {
    await _localizationService.initialize();
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLanguageChanged);
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer App',
      debugShowCheckedModeBanner: false,
      themeMode: _themeService.themeMode,
      theme: ThemeService.lightTheme,
      darkTheme: ThemeService.darkTheme,
      locale: _localizationService.currentLocale,
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthWrapper(),
    );
  }
}