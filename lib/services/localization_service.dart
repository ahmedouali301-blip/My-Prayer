import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Locale _currentLocale = const Locale('fr', 'FR');
  Locale get currentLocale => _currentLocale;

  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'), // Français
    Locale('ar', 'SA'), // العربية
    Locale('en', 'US'), // English
  ];

  // Initialize from saved preference
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'fr';
    final countryCode = prefs.getString('country_code') ?? 'FR';
    
    _currentLocale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  // Change language
  Future<void> changeLanguage(String languageName) async {
    Locale newLocale;
    
    switch (languageName) {
      case 'Français':
        newLocale = const Locale('fr', 'FR');
        break;
      case 'العربية':
        newLocale = const Locale('ar', 'SA');
        break;
      case 'English':
        newLocale = const Locale('en', 'US');
        break;
      default:
        newLocale = const Locale('fr', 'FR');
    }

    _currentLocale = newLocale;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
    await prefs.setString('country_code', newLocale.countryCode ?? '');
    
    notifyListeners();
  }

  // Get language name from locale
  String getLanguageName() {
    switch (_currentLocale.languageCode) {
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }
}

// Translations class
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Translation maps
  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      // Common
      'welcome': 'Bienvenue',
      'search': 'Rechercher...',
      'cancel': 'Annuler',
      'apply': 'Appliquer',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'close': 'Fermer',
      
      // Home
      'home': 'Accueil',
      'prayer_of_day': 'Prière du jour',
      'quran': 'Coran',
      'misbaha': 'Misbaha',
      'duas': 'Duas',
      'hijri_calendar': 'Calendrier Hijri',
      
      // Prayer Times
      'prayer_times': 'Horaires de prière',
      'fajr': 'Fajr',
      'sunrise': 'Lever du soleil',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      
      // Quran
      'holy_quran': 'القرآن الكريم',
      'surahs': 'Sourates',
      'verses': 'versets',
      'last_reading': 'Dernière lecture',
      'verse': 'Verset',
      
      // Settings
      'settings': 'Paramètres',
      'general_settings': 'Paramètres Généraux',
      'calculation_method': 'Méthode de calcul',
      'language': 'Langue',
      'theme': 'Thème',
      'notifications': 'Notifications',
      'about': 'À Propos',
      'light': 'Clair',
      'dark': 'Sombre',
      'system': 'Système',
      'enabled': 'Activées',
      'disabled': 'Désactivées',
      
      // Profile
      'my_profile': 'Mon Profil',
      'full_name': 'Nom complet',
      'email': 'Adresse email',
      'password': 'Mot de passe',
      'logout': 'Se déconnecter',
      'delete_account': 'Supprimer mon compte',
      'current_password': 'Mot de passe actuel',
      'new_password': 'Nouveau mot de passe',
      'confirm_password': 'Confirmer le mot de passe',
      
      // Messages
      'language_changed': 'Langue changée',
      'theme_updated': 'Thème mis à jour',
      'notifications_enabled': 'Notifications activées',
      'notifications_disabled': 'Notifications désactivées',
      'verse_copied': 'Verset copié',
      'marked_as_read': 'Marqué comme dernière lecture',
      'marker_removed': 'Marqueur retiré',
    },
    'ar': {
      // Common
      'welcome': 'مرحبا',
      'search': 'بحث...',
      'cancel': 'إلغاء',
      'apply': 'تطبيق',
      'save': 'حفظ',
      'delete': 'حذف',
      'close': 'إغلاق',
      
      // Home
      'home': 'الرئيسية',
      'prayer_of_day': 'صلاة اليوم',
      'quran': 'القرآن',
      'misbaha': 'المسبحة',
      'duas': 'الأدعية',
      'hijri_calendar': 'التقويم الهجري',
      
      // Prayer Times
      'prayer_times': 'مواقيت الصلاة',
      'fajr': 'الفجر',
      'sunrise': 'الشروق',
      'dhuhr': 'الظهر',
      'asr': 'العصر',
      'maghrib': 'المغرب',
      'isha': 'العشاء',
      
      // Quran
      'holy_quran': 'القرآن الكريم',
      'surahs': 'السور',
      'verses': 'آيات',
      'last_reading': 'آخر قراءة',
      'verse': 'آية',
      
      // Settings
      'settings': 'الإعدادات',
      'general_settings': 'الإعدادات العامة',
      'calculation_method': 'طريقة الحساب',
      'language': 'اللغة',
      'theme': 'المظهر',
      'notifications': 'الإشعارات',
      'about': 'حول',
      'light': 'فاتح',
      'dark': 'داكن',
      'system': 'النظام',
      'enabled': 'مفعل',
      'disabled': 'معطل',
      
      // Profile
      'my_profile': 'ملفي الشخصي',
      'full_name': 'الاسم الكامل',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'logout': 'تسجيل الخروج',
      'delete_account': 'حذف الحساب',
      'current_password': 'كلمة المرور الحالية',
      'new_password': 'كلمة المرور الجديدة',
      'confirm_password': 'تأكيد كلمة المرور',
      
      // Messages
      'language_changed': 'تم تغيير اللغة',
      'theme_updated': 'تم تحديث المظهر',
      'notifications_enabled': 'تم تفعيل الإشعارات',
      'notifications_disabled': 'تم تعطيل الإشعارات',
      'verse_copied': 'تم نسخ الآية',
      'marked_as_read': 'تم وضع علامة كآخر قراءة',
      'marker_removed': 'تم إزالة العلامة',
    },
    'en': {
      // Common
      'welcome': 'Welcome',
      'search': 'Search...',
      'cancel': 'Cancel',
      'apply': 'Apply',
      'save': 'Save',
      'delete': 'Delete',
      'close': 'Close',
      
      // Home
      'home': 'Home',
      'prayer_of_day': 'Prayer of the day',
      'quran': 'Quran',
      'misbaha': 'Misbaha',
      'duas': 'Duas',
      'hijri_calendar': 'Hijri Calendar',
      
      // Prayer Times
      'prayer_times': 'Prayer Times',
      'fajr': 'Fajr',
      'sunrise': 'Sunrise',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      
      // Quran
      'holy_quran': 'Holy Quran',
      'surahs': 'Surahs',
      'verses': 'verses',
      'last_reading': 'Last reading',
      'verse': 'Verse',
      
      // Settings
      'settings': 'Settings',
      'general_settings': 'General Settings',
      'calculation_method': 'Calculation Method',
      'language': 'Language',
      'theme': 'Theme',
      'notifications': 'Notifications',
      'about': 'About',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      
      // Profile
      'my_profile': 'My Profile',
      'full_name': 'Full Name',
      'email': 'Email Address',
      'password': 'Password',
      'logout': 'Logout',
      'delete_account': 'Delete Account',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_password': 'Confirm Password',
      
      // Messages
      'language_changed': 'Language changed',
      'theme_updated': 'Theme updated',
      'notifications_enabled': 'Notifications enabled',
      'notifications_disabled': 'Notifications disabled',
      'verse_copied': 'Verse copied',
      'marked_as_read': 'Marked as last reading',
      'marker_removed': 'Marker removed',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Shorthand method
  String t(String key) => translate(key);
}

// Delegate for AppLocalizations
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}