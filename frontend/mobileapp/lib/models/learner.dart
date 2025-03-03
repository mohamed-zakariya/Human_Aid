class Learner{
  final String? parentId;
  final String name;
  final String username;
  final String? password;
  final String nationality;
  final String birthdate;
  final String gender;
  // String? accessToken;
  // String? refreshToken;

  Learner({
    this.parentId,
    required this.name,
    required this.username,
    this.password,
    required this.nationality,
    required this.birthdate,
    required this.gender,
    // this.accessToken,
    // this.refreshToken
  });

  factory Learner.fromJson(Map<String, dynamic> json, [String? parentId]) {
    return Learner(
      parentId: parentId,
      name: json["name"] ?? "Unknown",
      username: json["username"] ?? "Unknown",
      birthdate: json["birthdate"] ?? "2000-01-01",
      nationality: json["nationality"] ?? "Unknown",
      gender: json["gender"] ?? "Unknown",
      // accessToken: accessToken ?? json["accessToken"],
      // refreshToken: refreshToken ?? json["refreshToken"],
    );
  }

}