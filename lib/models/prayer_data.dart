import 'location.dart';
import 'prayer_time.dart';
class PrayerData {
  final String currentPrayer;
  final String currentTime;
  final Location location;
  final List<PrayerTime> prayerTimes;
  final String hijriDate;

  PrayerData({
    required this.currentPrayer,
    required this.currentTime,
    required this.location,
    required this.prayerTimes,
    required this.hijriDate,
  });

  factory PrayerData.fromJson(Map<String, dynamic> json) {
    return PrayerData(
      currentPrayer: json['currentPrayer'] ?? '',
      currentTime: json['currentTime'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      prayerTimes: (json['prayerTimes'] as List?)
          ?.map((e) => PrayerTime.fromJson(e))
          .toList() ?? [],
      hijriDate: json['hijriDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPrayer': currentPrayer,
      'currentTime': currentTime,
      'location': location.toJson(),
      'prayerTimes': prayerTimes.map((e) => e.toJson()).toList(),
      'hijriDate': hijriDate,
    };
  }
}