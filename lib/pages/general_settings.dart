import 'package:flutter/material.dart';
import '../services/themes_service.dart';
import '../services/localization_service.dart';
import '../services/notification_service.dart'; // ✅ AJOUTÉ
import 'bottom_nav.dart';
import 'home_page.dart';
import 'prayer_times_page.dart';
import 'qibla_page.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({Key? key}) : super(key: key);

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ThemeService _themeService = ThemeService();
  final LocalizationService _localizationService = LocalizationService();
  final NotificationService _notificationService = NotificationService(); // ✅ AJOUTÉ
  
  // Settings states
  String _selectedCalculationMethod = 'Tunisie';
  late String _selectedLanguage;
  late String _selectedTheme;
  bool _notificationsEnabled = true;
  
  // ✅ NOUVEAU : États pour chaque prière
  bool _fajrEnabled = true;
  bool _dhuhrEnabled = true;
  bool _asrEnabled = true;
  bool _maghribEnabled = true;
  bool _ishaEnabled = true;

  @override
  void initState() {
    super.initState();
    _selectedTheme = _themeService.getCurrentThemeString();
    _selectedLanguage = _localizationService.getLanguageName();
    _loadNotificationPreferences(); // ✅ AJOUTÉ
  }

  // ✅ NOUVEAU : Charger les préférences de notifications
  Future<void> _loadNotificationPreferences() async {
    final prefs = await _notificationService.getNotificationPreferences();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs['enabled'] ?? true;
        _fajrEnabled = prefs['fajr'] ?? true;
        _dhuhrEnabled = prefs['dhuhr'] ?? true;
        _asrEnabled = prefs['asr'] ?? true;
        _maghribEnabled = prefs['maghrib'] ?? true;
        _ishaEnabled = prefs['isha'] ?? true;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(isDark, loc),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchBar(isDark, loc),
                  const SizedBox(height: 16),
                  _buildSettingsList(isDark, loc),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildBottomNav(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B4965),
            const Color(0xFF2C6E8F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Center(
              child: Text(
                loc.t('general_settings'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: loc.t('search'),
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey,
            fontSize: 16,
          ),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSettingsList(bool isDark, AppLocalizations loc) {
    return Column(
      children: [
        _buildSettingItem(
          icon: Icons.calculate_outlined,
          title: loc.t('calculation_method'),
          subtitle: _selectedCalculationMethod,
          onTap: () => _showCalculationMethodDialog(isDark, loc),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.language_outlined,
          title: loc.t('language'),
          subtitle: _selectedLanguage,
          onTap: () => _showLanguageDialog(isDark, loc),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.palette_outlined,
          title: loc.t('theme'),
          subtitle: _selectedTheme,
          onTap: () => _showThemeDialog(isDark, loc),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.notifications_outlined,
          title: loc.t('notifications'),
          subtitle: _notificationsEnabled ? loc.t('enabled') : loc.t('disabled'),
          onTap: () => _showNotificationsDialog(isDark, loc),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.info_outline,
          title: loc.t('about'),
          onTap: () => _showAboutDialog(isDark, loc),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4965).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1B4965),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[400] : Colors.black87,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Language Dialog
  void _showLanguageDialog(bool isDark, AppLocalizations loc) {
    String tempSelection = _selectedLanguage;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4965).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Color(0xFF1B4965),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  loc.t('language'),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRadioOption(
                  'Français',
                  tempSelection,
                  (value) => setDialogState(() => tempSelection = value!),
                  isDark,
                  '🇫🇷',
                ),
                const Divider(),
                _buildRadioOption(
                  'العربية',
                  tempSelection,
                  (value) => setDialogState(() => tempSelection = value!),
                  isDark,
                  '🇸🇦',
                ),
                const Divider(),
                _buildRadioOption(
                  'English',
                  tempSelection,
                  (value) => setDialogState(() => tempSelection = value!),
                  isDark,
                  '🇬🇧',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  loc.t('cancel'),
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _localizationService.changeLanguage(tempSelection);
                  
                  setState(() {
                    _selectedLanguage = tempSelection;
                  });
                  
                  Navigator.pop(context);
                  _showSuccessSnackBar(loc.t('language_changed'));
                  
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const GeneralSettingsPage()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4965),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(loc.t('apply')),
              ),
            ],
          );
        },
      ),
    );
  }

  // Theme Dialog
  void _showThemeDialog(bool isDark, AppLocalizations loc) {
    String tempSelection = _selectedTheme;
    
    String displayTheme = tempSelection;
    if (tempSelection == 'Clair') displayTheme = loc.t('light');
    if (tempSelection == 'Sombre') displayTheme = loc.t('dark');
    if (tempSelection == 'Système') displayTheme = loc.t('system');
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4965).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.palette,
                    color: Color(0xFF1B4965),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  loc.t('theme'),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRadioOption(
                  loc.t('light'),
                  displayTheme,
                  (value) => setDialogState(() => displayTheme = value!),
                  isDark,
                  '☀️',
                ),
                const Divider(),
                _buildRadioOption(
                  loc.t('dark'),
                  displayTheme,
                  (value) => setDialogState(() => displayTheme = value!),
                  isDark,
                  '🌙',
                ),
                const Divider(),
                _buildRadioOption(
                  loc.t('system'),
                  displayTheme,
                  (value) => setDialogState(() => displayTheme = value!),
                  isDark,
                  '📱',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  loc.t('cancel'),
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  String serviceTheme = displayTheme;
                  if (displayTheme == loc.t('light')) serviceTheme = 'Clair';
                  if (displayTheme == loc.t('dark')) serviceTheme = 'Sombre';
                  if (displayTheme == loc.t('system')) serviceTheme = 'Système';
                  
                  _themeService.setThemeMode(serviceTheme);
                  
                  setState(() {
                    _selectedTheme = serviceTheme;
                  });
                  
                  Navigator.pop(context);
                  _showSuccessSnackBar(loc.t('theme_updated'));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4965),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(loc.t('apply')),
              ),
            ],
          );
        },
      ),
    );
  }

  // Calculation Method Dialog
  void _showCalculationMethodDialog(bool isDark, AppLocalizations loc) {
    String tempSelection = _selectedCalculationMethod;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4965).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calculate,
                    color: Color(0xFF1B4965),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.t('calculation_method'),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSimpleRadioOption('Tunisie', tempSelection, (value) => setDialogState(() => tempSelection = value!), isDark),
                  _buildSimpleRadioOption('Muslim World League', tempSelection, (value) => setDialogState(() => tempSelection = value!), isDark),
                  _buildSimpleRadioOption('ISNA', tempSelection, (value) => setDialogState(() => tempSelection = value!), isDark),
                  _buildSimpleRadioOption('Egyptian General', tempSelection, (value) => setDialogState(() => tempSelection = value!), isDark),
                  _buildSimpleRadioOption('Umm Al-Qura', tempSelection, (value) => setDialogState(() => tempSelection = value!), isDark),
                  _buildSimpleRadioOption('Karachi University', tempSelection, (value) => setDialogState(() => tempSelection = value!), isDark),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  loc.t('cancel'),
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() => _selectedCalculationMethod = tempSelection);
                  Navigator.pop(context);
                  _showSuccessSnackBar('${loc.t('calculation_method')}: $tempSelection');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4965),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(loc.t('apply')),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ NOTIFICATIONS DIALOG - COMPLÈTEMENT MIS À JOUR
  void _showNotificationsDialog(bool isDark, AppLocalizations loc) {
    bool tempNotifications = _notificationsEnabled;
    bool tempFajr = _fajrEnabled;
    bool tempDhuhr = _dhuhrEnabled;
    bool tempAsr = _asrEnabled;
    bool tempMaghrib = _maghribEnabled;
    bool tempIsha = _ishaEnabled;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4965).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Color(0xFF1B4965),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  loc.t('notifications'),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gérer vos notifications de prières',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ✅ Switch principal
                  SwitchListTile(
                    title: Text(
                      'Activer les notifications',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: tempNotifications,
                    onChanged: (value) {
                      setDialogState(() => tempNotifications = value);
                    },
                    activeColor: const Color(0xFF1B4965),
                  ),
                  if (tempNotifications) ...[
                    const Divider(),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Notifications pour:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ✅ Checkboxes fonctionnelles pour chaque prière
                    CheckboxListTile(
                      title: Row(
                        children: [
                          Text(
                            loc.t('fajr'),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          ),
                          const SizedBox(width: 8),
                          const Text('🌅', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      value: tempFajr,
                      onChanged: (value) {
                        setDialogState(() => tempFajr = value ?? true);
                      },
                      activeColor: const Color(0xFF1B4965),
                    ),
                    CheckboxListTile(
                      title: Row(
                        children: [
                          Text(
                            loc.t('dhuhr'),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          ),
                          const SizedBox(width: 8),
                          const Text('☀️', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      value: tempDhuhr,
                      onChanged: (value) {
                        setDialogState(() => tempDhuhr = value ?? true);
                      },
                      activeColor: const Color(0xFF1B4965),
                    ),
                    CheckboxListTile(
                      title: Row(
                        children: [
                          Text(
                            loc.t('asr'),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          ),
                          const SizedBox(width: 8),
                          const Text('🌤️', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      value: tempAsr,
                      onChanged: (value) {
                        setDialogState(() => tempAsr = value ?? true);
                      },
                      activeColor: const Color(0xFF1B4965),
                    ),
                    CheckboxListTile(
                      title: Row(
                        children: [
                          Text(
                            loc.t('maghrib'),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          ),
                          const SizedBox(width: 8),
                          const Text('🌇', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      value: tempMaghrib,
                      onChanged: (value) {
                        setDialogState(() => tempMaghrib = value ?? true);
                      },
                      activeColor: const Color(0xFF1B4965),
                    ),
                    CheckboxListTile(
                      title: Row(
                        children: [
                          Text(
                            loc.t('isha'),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          ),
                          const SizedBox(width: 8),
                          const Text('🌙', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      value: tempIsha,
                      onChanged: (value) {
                        setDialogState(() => tempIsha = value ?? true);
                      },
                      activeColor: const Color(0xFF1B4965),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  loc.t('cancel'),
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // ✅ SAUVEGARDER TOUTES LES PRÉFÉRENCES
                  await _notificationService.saveNotificationPreferences(
                    enabled: tempNotifications,
                    fajr: tempFajr,
                    dhuhr: tempDhuhr,
                    asr: tempAsr,
                    maghrib: tempMaghrib,
                    isha: tempIsha,
                  );
                  
                  // Mettre à jour l'état
                  setState(() {
                    _notificationsEnabled = tempNotifications;
                    _fajrEnabled = tempFajr;
                    _dhuhrEnabled = tempDhuhr;
                    _asrEnabled = tempAsr;
                    _maghribEnabled = tempMaghrib;
                    _ishaEnabled = tempIsha;
                  });
                  
                  // ✅ Re-planifier ou annuler les notifications
                  if (tempNotifications) {
                    // Les notifications seront re-planifiées au prochain chargement de HomePage
                    print('✅ Préférences sauvegardées - notifications seront re-planifiées');
                  } else {
                    await _notificationService.cancelAllNotifications();
                    print('🔕 Toutes les notifications annulées');
                  }
                  
                  Navigator.pop(context);
                  _showSuccessSnackBar(
                    tempNotifications ? loc.t('notifications_enabled') : loc.t('notifications_disabled'),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4965),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(loc.t('apply')),
              ),
            ],
          );
        },
      ),
    );
  }

  // About Dialog
  void _showAboutDialog(bool isDark, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B4965).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info,
                color: Color(0xFF1B4965),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              loc.t('about'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.mosque,
                  size: 64,
                  color: Color(0xFF1B4965),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Prière App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Cette application vous aide à suivre vos horaires de prières quotidiennes avec précision.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildInfoRow('Développeur', 'Votre Nom', isDark),
              const SizedBox(height: 12),
              _buildInfoRow('Email', 'contact@priereapp.com', isDark),
              const SizedBox(height: 12),
              _buildInfoRow('Site Web', 'www.priereapp.com', isDark),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  '© 2025 Prière App. Tous droits réservés.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4965),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(loc.t('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(
    String title,
    String groupValue,
    ValueChanged<String?> onChanged,
    bool isDark,
    String emoji,
  ) {
    final isSelected = title == groupValue;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF1B4965).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        value: title,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: const Color(0xFF1B4965),
        dense: true,
      ),
    );
  }

  Widget _buildSimpleRadioOption(
    String title,
    String groupValue,
    ValueChanged<String?> onChanged,
    bool isDark,
  ) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      value: title,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: const Color(0xFF1B4965),
      dense: true,
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return SharedBottomNav(
      currentIndex: 3,
      onHomePressed: (context) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      },
      onTimesPressed: (context) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PrayerTimesPage()),
        );
      },
      onQiblaPressed: (context) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const QiblaPage()),
        );
      },
      onSettingsPressed: (context) {},
    );
  }
}