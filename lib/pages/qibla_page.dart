import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'bottom_nav.dart';
import 'home_page.dart';
import 'prayer_times_page.dart';
import 'settings_page.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  double? _currentHeading;
  double? _qiblaDirection;
  bool _hasPermission = false;
  StreamSubscription<CompassEvent>? _compassSubscription;

  // Kaaba coordinates
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  @override
  void initState() {
    super.initState();
    _initCompass();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel(); // annuler l'écoute du compass
    super.dispose();
  }

  /// Initialise la boussole et demande la permission de localisation
  Future<void> _initCompass() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showLocationServiceDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    if (!mounted) return;
    setState(() => _hasPermission = true);

    await _calculateQiblaDirection();

    // Écoute des événements du compass
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (!mounted) return; // 🔹 vérification critique
      setState(() => _currentHeading = event.heading);
    });
  }

  /// Calcule la direction de la Qibla
  Future<void> _calculateQiblaDirection() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double qibla = _getQiblaDirection(position.latitude, position.longitude);

      if (!mounted) return; // 🔹 vérification critique
      setState(() => _qiblaDirection = qibla);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  /// Formule pour calculer la direction de la Qibla
  double _getQiblaDirection(double userLat, double userLng) {
    double lat1 = userLat * math.pi / 180;
    double lng1 = userLng * math.pi / 180;
    double lat2 = kaabaLat * math.pi / 180;
    double lng2 = kaabaLng * math.pi / 180;

    double dLng = lng2 - lng1;

    double y = math.sin(dLng) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    double bearing = math.atan2(y, x);
    bearing = bearing * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  /// Affiche un dialogue si le service de localisation est désactivé
  void _showLocationServiceDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Location Services Disabled',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          'Please enable location services to use the Qibla compass.',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4965),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _hasPermission
                ? _buildCompass()
                : _buildPermissionMessage(),
          ),
          SharedBottomNav(
            currentIndex: 2,
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
            onQiblaPressed: (context) {},
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
      child: const Center(
        child: Text(
          'Qibla',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCompass() {
    if (_currentHeading == null || _qiblaDirection == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    double angle = ((_qiblaDirection! - _currentHeading!) * math.pi / 180);
    int displayAngle = _qiblaDirection!.round();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4A574), width: 8),
                ),
              ),
              Transform.rotate(
                angle: angle,
                child: CustomPaint(
                  size: const Size(120, 120),
                  painter: CompassNeedlePainter(),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1B4965),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            '$displayAngle°',
            style: const TextStyle(
              color: Color(0xFFD4A574),
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, color: Colors.white, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Location permission is required to use the Qibla compass.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initCompass,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Grant Permission',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the compass needle
class CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final needleLength = size.width / 2;

    // North (gold)
    paint.color = const Color(0xFFD4A574);
    final northPath = Path()
      ..moveTo(center.dx, center.dy - needleLength)
      ..lineTo(center.dx - 15, center.dy)
      ..lineTo(center.dx, center.dy - 10)
      ..lineTo(center.dx + 15, center.dy)
      ..close();
    canvas.drawPath(northPath, paint);

    // South (darker)
    paint.color = const Color(0xFF8B7355);
    final southPath = Path()
      ..moveTo(center.dx, center.dy + needleLength)
      ..lineTo(center.dx - 15, center.dy)
      ..lineTo(center.dx, center.dy + 10)
      ..lineTo(center.dx + 15, center.dy)
      ..close();
    canvas.drawPath(southPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
