class Review {
  final int id;
  final String username;
  //final String email;
  final String title;
  final String description;
  final DateTime? createdAt;
  final int stars;
  final bool approved;

  const Review({
    required this.id,
    required this.username,
    // required this.email, --> information not publically exposed
    required this.title,
    required this.description,
    this.createdAt,
    required this.stars,
    this.approved = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      username: json['username'] as String,
      // email: json['email'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      stars: json['stars'] as int,
      approved: (json['approved'] as bool?) ?? false,
    );
  }
}
