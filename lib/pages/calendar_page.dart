import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bottom_nav.dart';
import 'home_page.dart';
import 'prayer_times_page.dart';
import 'qibla_page.dart';
import 'settings_page.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late HijriCalendar _currentHijriDate;
  late HijriCalendar _selectedDate;
  Map<String, Map<String, String>> _monthPrayerData = {};
  bool _isLoading = true;
  Position? _currentPosition;
  String _cityName = 'Tunis';

  @override
  void dispose() {
    // Cleanup: s'assurer qu'aucune opération async ne continue après dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentHijriDate = HijriCalendar.now();
    _selectedDate = HijriCalendar.now();
    _initializeCalendar();
  }

  Future<void> _initializeCalendar() async {
    await _getCurrentLocation();
    await _loadMonthPrayerTimes();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Location error: $e');
      // Utiliser Tunis par défaut
      _currentPosition = Position(
        latitude: 36.8065,
        longitude: 10.1815,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }

  Future<void> _loadMonthPrayerTimes() async {
    if (_currentPosition == null) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convertir le mois hijri en grégorien pour obtenir les dates
      final startOfMonth = HijriCalendar()
        ..hYear = _currentHijriDate.hYear
        ..hMonth = _currentHijriDate.hMonth
        ..hDay = 1;

      final gregorianDate = HijriCalendar().hijriToGregorian(
        startOfMonth.hYear,
        startOfMonth.hMonth,
        startOfMonth.hDay,
      );

      final month = gregorianDate.month;
      final year = gregorianDate.year;

      // API Aladhan pour obtenir les horaires du mois
      final url = Uri.parse(
        'https://api.aladhan.com/v1/calendar/$year/$month'
        '?latitude=${_currentPosition!.latitude}'
        '&longitude=${_currentPosition!.longitude}'
        '&method=3', // Method 3 = Muslim World League
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final monthData = data['data'] as List;

        _monthPrayerData.clear();

        for (var dayData in monthData) {
          final dateStr = dayData['date']['gregorian']['date'];
          final timings = dayData['timings'];

          _monthPrayerData[dateStr] = {
            'Fajr': _cleanTime(timings['Fajr']),
            'Sunrise': _cleanTime(timings['Sunrise']),
            'Dhuhr': _cleanTime(timings['Dhuhr']),
            'Asr': _cleanTime(timings['Asr']),
            'Maghrib': _cleanTime(timings['Maghrib']),
            'Isha': _cleanTime(timings['Isha']),
          };
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading prayer times: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _cleanTime(String time) {
    // Supprimer le fuseau horaire (ex: "05:30 (CET)" -> "05:30")
    return time.split(' ')[0];
  }

  int _getDaysInMonth(int year, int month) {
    if (month.isOdd) {
      return 30;
    } else if (month == 12) {
      return _isHijriLeapYear(year) ? 30 : 29;
    } else {
      return 29;
    }
  }

  bool _isHijriLeapYear(int year) {
    final yearInCycle = year % 30;
    return [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29].contains(yearInCycle);
  }

  String _getHijriMonthName(int month) {
    const monthNames = [
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
    return month >= 1 && month <= 12 ? monthNames[month] : '';
  }

  List<String> _getWeekdayAbbreviations() {
    return ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
  }

  int _getHijriWeekday(HijriCalendar hijriDate) {
    final gregorianDate = HijriCalendar().hijriToGregorian(
      hijriDate.hYear,
      hijriDate.hMonth,
      hijriDate.hDay,
    );
    return gregorianDate.weekday % 7;
  }

  String _getGregorianDateKey(HijriCalendar hijriDate) {
    final gregorianDate = HijriCalendar().hijriToGregorian(
      hijriDate.hYear,
      hijriDate.hMonth,
      hijriDate.hDay,
    );
    return '${gregorianDate.day.toString().padLeft(2, '0')}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildCalendarHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1B4965),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildWeekdayRow(isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Divider(
                                color: isDark ? Colors.grey[700] : Colors.grey[300],
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _buildCalendarGrid(isDark),
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              color: isDark ? Colors.grey[700] : Colors.grey[300],
                              thickness: 1,
                            ),
                            _buildPrayerTimesSection(isDark),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
            ),
            SharedBottomNav(
              currentIndex: 0,
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
              onSettingsPressed: (context) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B4965), Color(0xFF2C6E8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Calendrier Islamique',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
              ),
              Column(
                children: [
                  Text(
                    _getHijriMonthName(_currentHijriDate.hMonth),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_currentHijriDate.hYear} H',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow(bool isDark) {
    final weekdays = _getWeekdayAbbreviations();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: weekdays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          
          Color textColor = isDark ? Colors.white : Colors.black87;
          if (index == 5) textColor = const Color(0xFF00BCD4); // Vendredi
          if (index == 6) textColor = Colors.red; // Samedi
          
          return Expanded(
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    final totalDays = _getDaysInMonth(_currentHijriDate.hYear, _currentHijriDate.hMonth);

    final firstDayOfMonth = HijriCalendar()
      ..hYear = _currentHijriDate.hYear
      ..hMonth = _currentHijriDate.hMonth
      ..hDay = 1;

    final firstWeekday = _getHijriWeekday(firstDayOfMonth);

    List<Widget> dayWidgets = [];

    // Espaces vides avant le premier jour
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Jours du mois
    for (int day = 1; day <= totalDays; day++) {
      final dayDate = HijriCalendar()
        ..hYear = _currentHijriDate.hYear
        ..hMonth = _currentHijriDate.hMonth
        ..hDay = day;

      final isToday = day == HijriCalendar.now().hDay && 
                      _currentHijriDate.hMonth == HijriCalendar.now().hMonth &&
                      _currentHijriDate.hYear == HijriCalendar.now().hYear;

      final isSelected = day == _selectedDate.hDay &&
                        _currentHijriDate.hMonth == _selectedDate.hMonth &&
                        _currentHijriDate.hYear == _selectedDate.hYear;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = HijriCalendar()
                ..hYear = _currentHijriDate.hYear
                ..hMonth = _currentHijriDate.hMonth
                ..hDay = day;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1B4965)
                  : isToday
                      ? const Color(0xFF2C6E8F).withOpacity(0.3)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFF1B4965), width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      children: dayWidgets,
    );
  }

  Widget _buildPrayerTimesSection(bool isDark) {
    final dateKey = _getGregorianDateKey(_selectedDate);
    final prayerData = _monthPrayerData[dateKey];

    final gregorianDate = HijriCalendar().hijriToGregorian(
      _selectedDate.hYear,
      _selectedDate.hMonth,
      _selectedDate.hDay,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Horaires de Prière',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4965).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${gregorianDate.day}/${gregorianDate.month}/${gregorianDate.year}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B4965),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (prayerData == null)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Horaires non disponibles',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ...prayerData.entries.map((entry) {
            IconData icon;
            switch (entry.key) {
              case 'Fajr':
                icon = Icons.nightlight_round;
                break;
              case 'Sunrise':
                icon = Icons.wb_sunny_outlined;
                break;
              case 'Dhuhr':
                icon = Icons.wb_sunny;
                break;
              case 'Asr':
                icon = Icons.wb_twilight;
                break;
              case 'Maghrib':
                icon = Icons.brightness_3;
                break;
              case 'Isha':
                icon = Icons.nights_stay;
                break;
              default:
                icon = Icons.access_time;
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B4965).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFF1B4965),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B4965),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _changeMonth(int offset) {
    if (!mounted) return;

    setState(() {
      int newMonth = _currentHijriDate.hMonth + offset;
      int newYear = _currentHijriDate.hYear;
      
      while (newMonth > 12) {
        newMonth -= 12;
        newYear++;
      }
      while (newMonth < 1) {
        newMonth += 12;
        newYear--;
      }
      
      _currentHijriDate = HijriCalendar()
        ..hYear = newYear
        ..hMonth = newMonth
        ..hDay = 1;

      // Ajuster la date sélectionnée
      _selectedDate = HijriCalendar()
        ..hYear = newYear
        ..hMonth = newMonth
        ..hDay = 1;
    });
      
    _loadMonthPrayerTimes();
  }
}