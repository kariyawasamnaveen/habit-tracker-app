class Habit {
  final String name;
  final String colorHex;
  final bool isCompleted;

  Habit({
    required this.name,
    required this.colorHex,
    this.isCompleted = false,
  });

  Habit copyWith({
    String? name,
    String? colorHex,
    bool? isCompleted,
  }) {
    return Habit(
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      name: json['name'],
      colorHex: json['colorHex'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'colorHex': colorHex,
      'isCompleted': isCompleted,
    };
  }
}
