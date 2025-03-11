class Learner {
  final String? id;
  final String? parentId;
  final String name;
  final String username;
  final String? password;
  final String nationality;
  final String birthdate;
  final String gender;

  Learner({
    this.id,
    this.parentId,
    required this.name,
    required this.username,
    this.password,
    required this.nationality,
    required this.birthdate,
    required this.gender,
  });

factory Learner.fromJson(Map<String, dynamic> json, [String? parentId]) {
  return Learner(
    // Use the key 'id' from your GraphQL response
    id: json["id"],  
    parentId: parentId,
    name: json["name"] ?? "Unknown",
    username: json["username"] ?? "Unknown",
    birthdate: json["birthdate"] ?? "2000-01-01",
    nationality: json["nationality"] ?? "Unknown",
    gender: json["gender"] ?? "Unknown",
  );
}
}
