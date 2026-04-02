class Recipe {
  final String id;
  final String name;
  final String? imageUrl;
  final String? category;
  final String? duration;
  final double? rating;
  final List<String> ingredients;
  final List<String> instructions;

  const Recipe({
    required this.id,
    required this.name,
    this.imageUrl,
    this.category,
    this.duration,
    this.rating,
    this.ingredients = const [],
    this.instructions = const [],
  });
}
