import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt,
      'searchName': name.toLowerCase(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];

    return AppUser(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : createdAtValue is DateTime
              ? createdAtValue
              : DateTime.now(),
    );
  }
}

