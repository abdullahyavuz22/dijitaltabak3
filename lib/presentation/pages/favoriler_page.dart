import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/entities/recipe.dart';
import '../widgets/app_ui.dart';
import '../widgets/recipe_card.dart';

/// Favoriler sekmesi: favori tarifler.
class FavorilerPage extends StatelessWidget {
  final List<Recipe> recipes;
  final Set<String> favorites;
  final void Function(Recipe recipe) onToggleFavorite;

  /// "Tariflere göz at" butonu (boş durumda).
  final VoidCallback? onExplore;

  const FavorilerPage({
    super.key,
    required this.recipes,
    required this.favorites,
    required this.onToggleFavorite,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final favRecipes = recipes.where((r) => favorites.contains(r.id)).toList();
    return _TariflerTab(
      recipes: favRecipes,
      onToggleFavorite: onToggleFavorite,
      onExplore: onExplore,
    );
  }
}

class _TariflerTab extends StatelessWidget {
  const _TariflerTab({
    required this.recipes,
    required this.onToggleFavorite,
    this.onExplore,
  });

  final List<Recipe> recipes;
  final void Function(Recipe recipe) onToggleFavorite;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Favori tarifin yok',
        message:
            'Beğendiğin tariflerdeki kalp ikonuna dokun,\n'
            'hepsi burada toplansın.',
        action: onExplore == null
            ? null
            : FilledButton.icon(
                onPressed: onExplore,
                icon: const Icon(Icons.restaurant_menu_rounded),
                label: const Text('Tariflere Göz At'),
              ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      itemCount: recipes.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) => RecipeCard(
        recipe: recipes[i],
        isFavorite: true,
        onToggleFavorite: () => onToggleFavorite(recipes[i]),
      ),
    );
  }
}
