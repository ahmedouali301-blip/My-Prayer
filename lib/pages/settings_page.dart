import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../services/notification_service.dart'; // ✅ AJOUTÉ
import 'general_settings.dart';
import 'profil_page.dart';
import 'bottom_nav.dart';
import 'home_page.dart';
import 'prayer_times_page.dart';
import 'qibla_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final NotificationService _notificationService = NotificationService(); // ✅ AJOUTÉ
  bool _notificationsEnabled = true;
  final TextEditingController _searchController = TextEditingController();

  // ✅ NOUVEAU : Charger l'état des notifications au démarrage
  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  // ✅ NOUVEAU : Charger les préférences sauvegardées
  Future<void> _loadNotificationPreferences() async {
    final prefs = await _notificationService.getNotificationPreferences();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs['enabled'] ?? true;
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SharedBottomNav(
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
          ),
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
      child: Center(
        child: Text(
          loc.t('settings'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          icon: Icons.person_outline,
          title: loc.t('my_profile'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          },
          hasArrow: true,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.settings_outlined,
          title: loc.t('general_settings'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GeneralSettingsPage(),
              ),
            );
          },
          hasArrow: true,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.notifications_outlined,
          title: loc.t('notifications'),
          subtitle: _notificationsEnabled ? loc.t('enabled') : loc.t('disabled'),
          hasToggle: true,
          toggleValue: _notificationsEnabled,
          onToggle: (value) async {
            // ✅ NOUVEAU : Gestion de l'activation/désactivation
            await _handleNotificationToggle(value, loc);
          },
          isDark: isDark,
        ),
      ],
    );
  }

  // ✅ NOUVELLE MÉTHODE : Gérer l'activation/désactivation des notifications
  Future<void> _handleNotificationToggle(bool value, AppLocalizations loc) async {
    try {
      // Sauvegarder la préférence
      await _notificationService.saveNotificationPreferences(enabled: value);
      
      if (value) {
        // Activer : Re-planifier les notifications
        // Note : Les horaires seront rechargés depuis Firestore par HomePage
        print('✅ Notifications activées');
        
        // Afficher un message de confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.t('notifications_enabled'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } else {
        // Désactiver : Annuler toutes les notifications
        await _notificationService.cancelAllNotifications();
        print('🔕 Toutes les notifications annulées');
        
        // Afficher un message de confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.notifications_off, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.t('notifications_disabled'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF616161),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
      
      // Mettre à jour l'état
      setState(() {
        _notificationsEnabled = value;
      });
      
    } catch (e) {
      print('❌ Erreur lors de la gestion des notifications: $e');
      
      // Afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Erreur lors de la modification des notifications'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool hasArrow = false,
    bool hasToggle = false,
    bool? toggleValue,
    ValueChanged<bool>? onToggle,
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
          onTap: hasToggle ? null : onTap,
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
                if (hasArrow)
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey[400] : Colors.black87,
                    size: 28,
                  ),
                if (hasToggle)
                  Switch(
                    value: toggleValue ?? false,
                    onChanged: onToggle,
                    activeColor: const Color(0xFF1B4965),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}