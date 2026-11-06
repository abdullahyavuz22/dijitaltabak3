import '../../core/config/supabase_config.dart';
import '../../domain/entities/recipe.dart';
import '../models/recipe_model.dart';

/// Tarifler ve favoriler için Supabase erişimini kapsar.
class RecipeRepository {
  Future<List<Recipe>> fetchRecipes() async {
    final response = await SupabaseConfig.client
        .from('recipes')
        .select()
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Set<String>> fetchFavoriteIds() async {
    final userId = _userId;
    if (userId == null) return {};
    final response = await SupabaseConfig.client
        .from('favoriler')
        .select('recipe_id')
        .eq('user_id', userId);
    return (response as List)
        .where((e) => e['recipe_id'] != null)
        .map((e) => e['recipe_id'] as String)
        .toSet();
  }

  /// Tarif ekler. Sadece admin rolündeki kullanıcılar için izinlidir —
  /// yetkisi olmayan bir çağrı Supabase RLS tarafından reddedilir.
  Future<void> addRecipe({
    required String name,
    String? imageUrl,
    String? category,
    String? duration,
    double? rating,
    List<String> ingredients = const [],
    List<String> instructions = const [],
  }) async {
    await SupabaseConfig.client.from('recipes').insert({
      'name': name,
      'image_url': imageUrl,
      'category': category,
      'duration': duration,
      'rating': rating,
      'ingredients': ingredients,
      'instructions': instructions,
    });
  }

  Future<void> addFavorite(String recipeId) async {
    final userId = _userId;
    if (userId == null) return;
    await SupabaseConfig.client.from('favoriler').insert({
      'recipe_id': recipeId,
      'user_id': userId,
    });
  }

  Future<void> removeFavorite(String recipeId) async {
    final userId = _userId;
    if (userId == null) return;
    await SupabaseConfig.client
        .from('favoriler')
        .delete()
        .eq('recipe_id', recipeId)
        .eq('user_id', userId);
  }

  String? get _userId => SupabaseConfig.client.auth.currentUser?.id;
}
