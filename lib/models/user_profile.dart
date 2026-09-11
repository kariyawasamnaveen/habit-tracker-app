class UserProfile {
  final String name;
  final String username;
  final int age;
  final String country;

  UserProfile({
    required this.name,
    required this.username,
    required this.age,
    required this.country,
  });

  UserProfile copyWith({
    String? name,
    String? username,
    int? age,
    String? country,
  }) {
    return UserProfile(
      name: name ?? this.name,
      username: username ?? this.username,
      age: age ?? this.age,
      country: country ?? this.country,
    );
  }
}
