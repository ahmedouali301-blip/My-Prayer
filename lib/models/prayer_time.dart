class PrayerTime {
  final String name;
  final String time;
  final bool isNext;

  PrayerTime({
    required this.name,
    required this.time,
    this.isNext = false,
  });

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      isNext: json['isNext'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time,
      'isNext': isNext,
    };
  }
}