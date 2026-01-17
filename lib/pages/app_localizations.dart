import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      // Home Page
      'welcome': 'Bienvenue',
      'home': 'Accueil',
      'prayer_of_the_day': 'Priére du jour',
      'next_prayer': 'Prochaine Priére',
      'in_time': 'Dans',
      
      // Navigation
      'calendar': 'Calendrier',
      'qibla': 'Qibla',
      'settings': 'Paramétres',
      'times': 'Horaires',
      'duas': 'Duas',
      
      // Prayer names
      'fajr': 'Fajr',
      'chourouq': 'Chourouq',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghreb': 'Maghreb',
      'isha': 'Isha',
      'waqtu_fajr': 'Waqtu Fajr',
      'waqtu_dhuhr': 'Waqtu Dhuhr',
      'waqtu_asr': 'Waqtu Asr',
      'waqtu_maghrib': 'Waqtu Maghrib',
      'waqtu_isha': 'Waqtu Isha',
      
      // Quick Actions
      'quran': 'Coran',
      'misbaha': 'Misbaha',
      
      // Settings
      'general': 'Général',
      'language': 'Langue',
      'notifications': 'Notifications',
      'search': 'Rechercher',
      
      // Calendar
      'hijri_calendar': 'Calendrier Hijri',
      'previous_month': 'Mois précédent',
      'next_month': 'Mois suivant',
      'prayer_schedule': 'Jadwal',
      
      // Buttons
      'cancel': 'Annuler',
      'ok': 'OK',
      'save': 'Enregistrer',
      
      // Messages
      'language_updated': 'Langue mise à jour',
      'coming_soon': 'Cette fonctionnalité sera bientôt disponible.',
      'location_permission_required': 'La permission de localisation est requise pour utiliser la boussole Qibla.',
      'grant_permission': 'Accorder la permission',
      'location_services_disabled': 'Services de localisation désactivés',
      'enable_location_services': 'Veuillez activer les services de localisation pour utiliser la boussole Qibla.',
      
      // Days of week
      'sunday': 'D',
      'monday': 'L',
      'tuesday': 'M',
      'wednesday': 'M',
      'thursday': 'J',
      'friday': 'V',
      'saturday': 'S',
    },
    'en': {
      // Home Page
      'welcome': 'Welcome',
      'home': 'Home',
      'prayer_of_the_day': 'Prayer of the Day',
      'next_prayer': 'Next Prayer',
      'in_time': 'In',
      
      // Navigation
      'calendar': 'Calendar',
      'qibla': 'Qibla',
      'settings': 'Settings',
      'times': 'Times',
      'duas': 'Duas',
      
      // Prayer names
      'fajr': 'Fajr',
      'chourouq': 'Sunrise',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghreb': 'Maghreb',
      'isha': 'Isha',
      'waqtu_fajr': 'Fajr Time',
      'waqtu_dhuhr': 'Dhuhr Time',
      'waqtu_asr': 'Asr Time',
      'waqtu_maghrib': 'Maghreb Time',
      'waqtu_isha': 'Isha Time',
      
      // Quick Actions
      'quran': 'Quran',
      'misbaha': 'Misbaha',
      
      // Settings
      'general': 'General',
      'language': 'Language',
      'notifications': 'Notifications',
      'search': 'Search',
      
      // Calendar
      'hijri_calendar': 'Hijri Calendar',
      'previous_month': 'Previous Month',
      'next_month': 'Next Month',
      'prayer_schedule': 'Schedule',
      
      // Buttons
      'cancel': 'Cancel',
      'ok': 'OK',
      'save': 'Save',
      
      // Messages
      'language_updated': 'Language updated',
      'coming_soon': 'This feature will be available soon.',
      'location_permission_required': 'Location permission is required to use the Qibla compass.',
      'grant_permission': 'Grant Permission',
      'location_services_disabled': 'Location Services Disabled',
      'enable_location_services': 'Please enable location services to use the Qibla compass.',
      
      // Days of week
      'sunday': 'S',
      'monday': 'M',
      'tuesday': 'T',
      'wednesday': 'W',
      'thursday': 'T',
      'friday': 'F',
      'saturday': 'S',
    },
    'ar': {
      // Home Page
      'welcome': 'مرحباً',
      'home': 'الرئيسية',
      'prayer_of_the_day': 'صلاة اليوم',
      'next_prayer': 'الصلاة القادمة',
      'in_time': 'بعد',
      
      // Navigation
      'calendar': 'التقويم',
      'qibla': 'القبلة',
      'settings': 'الإعدادات',
      'times': 'الأوقات',
      'duas': 'الأدعية',
      
      // Prayer names
      'fajr': 'الفجر',
      'chourouq': 'الشروق',
      'dhuhr': 'الظهر',
      'asr': 'العصر',
      'maghreb': 'المغرب',
      'isha': 'العشاء',
      'waqtu_fajr': 'وقت الفجر',
      'waqtu_dhuhr': 'وقت الظهر',
      'waqtu_asr': 'وقت العصر',
      'waqtu_maghrib': 'وقت المغرب',
      'waqtu_isha': 'وقت العشاء',
      
      // Quick Actions
      'quran': 'القرآن',
      'misbaha': 'المسبحة',
      
      // Settings
      'general': 'عام',
      'language': 'اللغة',
      'notifications': 'الإشعارات',
      'search': 'بحث',
      
      // Calendar
      'hijri_calendar': 'التقويم الهجري',
      'previous_month': 'الشهر السابق',
      'next_month': 'الشهر التالي',
      'prayer_schedule': 'جدول الصلاة',
      
      // Buttons
      'cancel': 'إلغاء',
      'ok': 'موافق',
      'save': 'حفظ',
      
      // Messages
      'language_updated': 'تم تحديث اللغة',
      'coming_soon': 'ستتوفر هذه الميزة قريباً.',
      'location_permission_required': 'يتطلب إذن الموقع لاستخدام بوصلة القبلة.',
      'grant_permission': 'منح الإذن',
      'location_services_disabled': 'خدمات الموقع معطلة',
      'enable_location_services': 'يرجى تفعيل خدمات الموقع لاستخدام بوصلة القبلة.',
      
      // Days of week
      'sunday': 'ح',
      'monday': 'ن',
      'tuesday': 'ث',
      'wednesday': 'ر',
      'thursday': 'خ',
      'friday': 'ج',
      'saturday': 'س',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Shorthand for translate
  String t(String key) => translate(key);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}