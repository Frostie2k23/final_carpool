class UserModel {
  final String id;
  final String email;
  final String type;
  final String? parentEmail;

  UserModel(
      {required this.id,
      required this.email,
      required this.type,
      this.parentEmail});

  // method to convert UserModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'type': type,
      'parent_email': parentEmail
    };
  }

  // factory method to convert JSON to UserModel object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        type: json['type'] as String,
        parentEmail: json['parent_email'] as String);
  }
}
