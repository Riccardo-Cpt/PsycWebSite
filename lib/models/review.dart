class Review {
  final int id;
  final String username;
  final String title;
  final String description;
  final DateTime? createdAt;
  final int stars;
  final bool approved;
  final String? name;
  final String? surname;
  final String? userEmail;

  const Review({
    required this.id,
    required this.username,
    required this.title,
    required this.description,
    this.createdAt,
    required this.stars,
    this.approved = false,
    this.name,
    this.surname,
    this.userEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final user = json['reviewer_users'] as Map<String, dynamic>?;
    return Review(
      id: json['id'] as int,
      username: json['username'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      stars: json['stars'] as int,
      approved: (json['approved'] as bool?) ?? false,
      name: user?['name'] as String?,
      surname: user?['surname'] as String?,
      userEmail: user?['email'] as String?,
    );
  }
}
