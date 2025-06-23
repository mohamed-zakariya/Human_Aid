class Learner {
  final String? id;
  final String? parentId;
  final String name;
  final String username;
  final String? password;
  final String? email;
  final String nationality;
  final String birthdate;
  final String gender;
  final String? parentName;
  final int? totalTimeSpent;

  Learner({
    this.id,
    this.parentId,
    required this.name,
    required this.username,
    this.password,
    this.email,
    required this.nationality,
    required this.birthdate,
    required this.gender,
    this.parentName,
    this.totalTimeSpent,
  });

  factory Learner.fromJson(Map<String, dynamic> json, [String? parentId]) {
    return Learner(
      // Use the key 'id' from your GraphQL response
      id: json["id"],
      parentId: parentId,
      name: json["name"] ?? "Unknown",
      username: json["username"] ?? "Unknown",
      email: json["email"],
      birthdate: json["birthdate"] ?? "2000-01-01",
      nationality: json["nationality"] ?? "Unknown",
      gender: json["gender"] ?? "Unknown",
      parentName: json["parentName"],
      totalTimeSpent: json["totalTimeSpent"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'name': name,
      'username': username,
      'email': email,
      'nationality': nationality,
      'birthdate': birthdate,
      'gender': gender,
      'parentName': parentName,
      'totalTimeSpent': totalTimeSpent,
    };
  }

  Learner copyWith({
    String? id,
    String? parentId,
    String? name,
    String? username,
    String? password,
    String? email,
    String? nationality,
    String? birthdate,
    String? gender,
    String? parentName,
    int? totalTimeSpent,
  }) {
    return Learner(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      nationality: nationality ?? this.nationality,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      parentName: parentName ?? this.parentName,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
    );
  }
}