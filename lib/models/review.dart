class Review {
  final int id;
  final String name;
  final String description;
  final DateTime? createdAt;
  final int stars;

  const Review({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
    required this.stars,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as int,
        name: json['Name'] as String,
        description: json['Description'] as String,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        stars: json['stars'] as int,
      );
}
