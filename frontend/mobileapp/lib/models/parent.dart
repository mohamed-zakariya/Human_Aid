import 'package:intl/intl.dart';

class Parent {
  final String? id;
  final String name;
  final String email;
  final String? password; // Nullable since it's not always required
  final String phoneNumber;
  final String birthdate;
  final String nationality;
  final String gender;
  // final String? accessToken;
  // final String? refreshToken;

  // ✅ Default Constructor (Without Password)
  Parent({
    this.id,
    required this.name,
    required this.email,
    this.password, // Optional
    required this.phoneNumber,
    required this.birthdate,
    required this.nationality,
    required this.gender,
    // this.accessToken,
    // this.refreshToken,
  });


  // ✅ Factory Constructor for JSON Parsing (Without Password)
  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      phoneNumber: json["phoneNumber"]?? "",
      birthdate: json["birthdate"]?? "",
      nationality: json["nationality"]?? "",
      gender: json["gender"]?? "",
      // accessToken: accessToken,
    );
  }
}
