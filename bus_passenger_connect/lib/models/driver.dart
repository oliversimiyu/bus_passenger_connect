class Driver {
  final String id;
  final String name;
  final String idNumber;
  final String licensePlate;
  final String busCompany;
  final int age;
  final String phone;
  final String? email;
  final String? licenseNumber;
  final int? experienceYears;
  final String status;
  final String? qrCode;
  final String? authToken;
  final DateTime? tokenExpiry;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Driver({
    required this.id,
    required this.name,
    required this.idNumber,
    required this.licensePlate,
    required this.busCompany,
    required this.age,
    required this.phone,
    this.email,
    this.licenseNumber,
    this.experienceYears,
    required this.status,
    this.qrCode,
    this.authToken,
    this.tokenExpiry,
    this.createdAt,
    this.updatedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      idNumber: json['idNumber'],
      licensePlate: json['licensePlate'],
      busCompany: json['busCompany'],
      age: json['age'],
      phone: json['phone'],
      email: json['email'],
      licenseNumber: json['licenseNumber'],
      experienceYears: json['experienceYears'],
      status: json['status'],
      qrCode: json['qrCode'],
      authToken: json['authToken'],
      tokenExpiry: json['tokenExpiry'] != null
          ? DateTime.parse(json['tokenExpiry'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'idNumber': idNumber,
      'licensePlate': licensePlate,
      'busCompany': busCompany,
      'age': age,
      'phone': phone,
      'email': email,
      'licenseNumber': licenseNumber,
      'experienceYears': experienceYears,
      'status': status,
      'qrCode': qrCode,
      'authToken': authToken,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Driver copyWith({
    String? id,
    String? name,
    String? idNumber,
    String? licensePlate,
    String? busCompany,
    int? age,
    String? phone,
    String? email,
    String? licenseNumber,
    int? experienceYears,
    String? status,
    String? qrCode,
    String? authToken,
    DateTime? tokenExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      idNumber: idNumber ?? this.idNumber,
      licensePlate: licensePlate ?? this.licensePlate,
      busCompany: busCompany ?? this.busCompany,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      experienceYears: experienceYears ?? this.experienceYears,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      authToken: authToken ?? this.authToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isSuspended => status == 'suspended';
}
