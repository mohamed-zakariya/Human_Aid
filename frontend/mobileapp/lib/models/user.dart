class User{
  final String id;
  final String name;
  final String username;
  final String token;


  User({
    required this.id,
    required this.name,
    required this.username,
    required this.token
  });

  factory User.fromJson(Map<String, dynamic> json, String token){
    return User(id: json["id"],
        name: json["name"],
        username: json["username"],
        token: token
    );
  }
}