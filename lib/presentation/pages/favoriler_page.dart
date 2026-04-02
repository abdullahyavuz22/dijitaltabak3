import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/recipe.dart';
import 'recipe_detay_page.dart';

class FavorilerPage extends StatelessWidget {
  final List<Recipe> recipes;
  final Set<String> favorites;
  final void Function(Recipe recipe) onToggleFavorite;

  const FavorilerPage({
    super.key,
    required this.recipes,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final favRecipes =
        recipes.where((r) => favorites.contains(r.id)).toList();

    if (favRecipes.isEmpty) {
      return const Center(
        child: Text(
          'Henüz favori yemek eklenmedi.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: favRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favRecipes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetayPage(recipe: recipe),
                ),
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (recipe.imageUrl != null)
                      Image.network(
                        recipe.imageUrl!,
                        height: 160,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: const Icon(Icons.restaurant,
                              size: 48, color: Colors.grey),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                if (recipe.duration != null ||
                                    recipe.rating != null)
                                  const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (recipe.duration != null) ...[
                                      const Icon(Icons.timer_outlined,
                                          size: 13, color: AppColors.primary),
                                      const SizedBox(width: 3),
                                      Text(
                                        recipe.duration!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    if (recipe.rating != null) ...[
                                      const Icon(Icons.star_rounded,
                                          size: 13, color: Colors.amber),
                                      const SizedBox(width: 3),
                                      Text(
                                        recipe.rating!.toStringAsFixed(1),
                                        style:
                                            const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite,
                                color: Colors.red),
                            onPressed: () => onToggleFavorite(recipe),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
