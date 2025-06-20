class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? authToken;
  final DateTime? tokenExpiry;
  final bool useBiometrics;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.authToken,
    this.tokenExpiry,
    this.useBiometrics = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      authToken: json['authToken'] as String?,
      tokenExpiry: json['tokenExpiry'] != null
          ? DateTime.parse(json['tokenExpiry'])
          : null,
      useBiometrics: json['useBiometrics'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'authToken': authToken,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'useBiometrics': useBiometrics,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? authToken,
    DateTime? tokenExpiry,
    bool? useBiometrics,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      authToken: authToken ?? this.authToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      useBiometrics: useBiometrics ?? this.useBiometrics,
    );
  }

  bool get isTokenValid {
    if (authToken == null || tokenExpiry == null) return false;
    return tokenExpiry!.isAfter(DateTime.now());
  }
}
