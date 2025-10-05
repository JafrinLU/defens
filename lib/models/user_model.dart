class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String status;
  final List<String> skills;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.status = 'approved',
    this.skills = const [],
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'N/A',
      email: data['email'] ?? 'N/A',
      role: data['role'] ?? 'student',
      status: data['status'] ?? 'approved',
      skills: List<String>.from(data['skills'] ?? []),
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'skills': skills,
      'photoUrl': photoUrl,
    };
  }
}