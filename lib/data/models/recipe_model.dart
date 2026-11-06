import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.category,
    super.duration,
    super.rating,
    super.ingredients,
    super.instructions,
    super.description,
    super.region,
    super.servings,
    super.prepTime,
    super.cookTime,
    super.tips,
    super.nutritionAdvice,
    super.dietitianNote,
    super.nutrition,
    super.nutritionTotal,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      category: json['category']?.toString(),
      duration: json['duration']?.toString(),
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      ingredients: _parseArray(json['ingredients']),
      instructions: _parseArray(json['instructions']),
      description: _text(json['description']),
      region: _text(json['region']),
      servings: _text(json['servings']),
      prepTime: _text(json['prep_time']),
      cookTime: _text(json['cook_time']),
      tips: _text(json['tips']),
      nutritionAdvice: _text(json['nutrition_advice']),
      dietitianNote: _text(json['dietitian_note']),
      nutrition: _parseBesin(json['nutrition']),
      nutritionTotal: _parseBesin(json['nutrition_total']),
    );
  }

  static String? _text(dynamic v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  /// `[{"ad": "Enerji", "miktar": "~200 kcal"}, ...]`
  static List<BesinOgesi> _parseBesin(dynamic value) {
    if (value is! List) return const [];
    return [
      for (final e in value)
        if (e is Map && e['ad'] != null && e['miktar'] != null)
          BesinOgesi(ad: e['ad'].toString(), miktar: e['miktar'].toString()),
    ];
  }

  static List<String> _parseArray(dynamic value) {
    if (value == null) return [];

    // Supabase'den JSON array olarak geliyorsa (ingredients gibi)
    if (value is List) {
      return value
          .map(
            (e) => e
                .toString()
                .replaceAll('\r\n', ' ')
                .replaceAll('\n', ' ')
                .trim(),
          )
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) return [];

    // PostgreSQL array literal: {"adım1","adım2","adım3"}
    if (raw.startsWith('{') && raw.endsWith('}')) {
      final inner = raw.substring(1, raw.length - 1);
      final items = <String>[];
      final regex = RegExp(r'"((?:[^"\\]|\\.)*)"');
      for (final match in regex.allMatches(inner)) {
        final item = match
            .group(1)!
            .replaceAll('\\"', '"')
            .replaceAll('\\\\', '\\')
            .replaceAll('\r\n', ' ')
            .replaceAll('\n', ' ')
            .trim();
        if (item.isNotEmpty) items.add(item);
      }
      // Tırnak içermeyen basit değerler
      if (items.isEmpty) {
        return inner
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return items;
    }

    // Düz metin — tek madde olarak döndür
    return [raw];
  }
}
