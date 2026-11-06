/// Besin öğesi satırı (örn. Enerji – ~200 kcal).
class BesinOgesi {
  final String ad;
  final String miktar;

  const BesinOgesi({required this.ad, required this.miktar});
}

class Recipe {
  final String id;
  final String name;

  /// Ağ adresi veya `assets/...` ile başlayan yerel görsel yolu.
  final String? imageUrl;
  final String? category;

  /// Toplam süre (kartlarda gösterilir, örn. "55 dk").
  final String? duration;
  final double? rating;

  /// Malzemeler. ":" ile biten öğeler grup başlığıdır (örn. "Et için:").
  final List<String> ingredients;
  final List<String> instructions;

  final String? description;
  final String? region;
  final String? servings;
  final String? prepTime;
  final String? cookTime;
  final String? tips;
  final String? nutritionAdvice;
  final String? dietitianNote;

  /// 1 porsiyon besin değerleri.
  final List<BesinOgesi> nutrition;

  /// Tarifin tamamı için besin değerleri.
  final List<BesinOgesi> nutritionTotal;

  const Recipe({
    required this.id,
    required this.name,
    this.imageUrl,
    this.category,
    this.duration,
    this.rating,
    this.ingredients = const [],
    this.instructions = const [],
    this.description,
    this.region,
    this.servings,
    this.prepTime,
    this.cookTime,
    this.tips,
    this.nutritionAdvice,
    this.dietitianNote,
    this.nutrition = const [],
    this.nutritionTotal = const [],
  });

  /// Grup başlıkları hariç malzeme sayısı.
  int get ingredientCount =>
      ingredients.where((i) => !isIngredientHeader(i)).length;

  static bool isIngredientHeader(String s) => s.trimRight().endsWith(':');
}
