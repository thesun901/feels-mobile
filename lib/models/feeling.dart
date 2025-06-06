class Feeling {
  final String name;
  final String color;

  Feeling({
    required this.name,
    required this.color,
  });

  factory Feeling.fromJson(Map<String, dynamic> json) {
    return Feeling(
      name: json['name'],
      color: json['color'],
    );
  }
}