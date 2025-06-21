// User profile data model
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final List<String> favoriteRouteIds;
  final List<Map<String, dynamic>> travelHistory;
  final List<dynamic> favoriteRoutes;

  UserProfile({
    this.id = 'guest',
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.favoriteRouteIds = const [],
    this.travelHistory = const [],
    this.favoriteRoutes = const [],
  });

  // Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    List<String>? favoriteRouteIds,
    List<Map<String, dynamic>>? travelHistory,
    List<dynamic>? favoriteRoutes,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      favoriteRouteIds: favoriteRouteIds ?? this.favoriteRouteIds,
      travelHistory: travelHistory ?? this.travelHistory,
      favoriteRoutes: favoriteRoutes ?? this.favoriteRoutes,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'favoriteRouteIds': favoriteRouteIds,
      'travelHistory': travelHistory,
      'favoriteRoutes': favoriteRoutes,
    };
  }

  // Create from JSON data
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 'guest',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      favoriteRouteIds: List<String>.from(json['favoriteRouteIds'] ?? []),
      travelHistory: List<Map<String, dynamic>>.from(
        json['travelHistory'] ?? [],
      ),
      favoriteRoutes: List.from(json['favoriteRoutes'] ?? []),
    );
  }
}
