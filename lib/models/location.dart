class Location {
  final String city;
  final String country;
  final double latitude;
  final double longitude;

  Location({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}