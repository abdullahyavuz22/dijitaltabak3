import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/entities/recipe.dart';
import '../pages/recipe_detay_page.dart';
import 'app_ui.dart';

/// Görselli tarif kartı (Anasayfa, Favoriler, Tarifler).
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final Recipe recipe;
  final bool isFavorite;

  /// Null ise favori butonu gösterilmez.
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () => openRecipe(context, recipe),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: NetworkThumb(url: recipe.imageUrl),
                ),
                if (recipe.category != null && recipe.category!.isNotEmpty)
                  Positioned(
                    left: AppSpacing.sm,
                    top: AppSpacing.sm,
                    child: _GlassLabel(recipe.category!),
                  ),
                if (onToggleFavorite != null)
                  Positioned(
                    right: AppSpacing.xs,
                    top: AppSpacing.xs,
                    child: FavoriteButton(
                      isFavorite: isFavorite,
                      onPressed: onToggleFavorite!,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (recipe.duration != null || recipe.rating != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (recipe.duration != null)
                          InfoPill(
                            icon: Icons.schedule_rounded,
                            label: recipe.duration!,
                          ),
                        if (recipe.rating != null)
                          InfoPill(
                            icon: Icons.star_rounded,
                            label: recipe.rating!.toStringAsFixed(1),
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppColors.star
                                : const Color(0xFFB27C00),
                          ),
                      ],
                    ),
                  ],
                  if (recipe.ingredients.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${recipe.ingredients.length} malzeme',
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Liste görünümü için küçük görselli tarif satırı (Arama).
class RecipeTile extends StatelessWidget {
  const RecipeTile({
    super.key,
    required this.recipe,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final meta = [
      if (recipe.category != null) recipe.category!,
      if (recipe.duration != null) recipe.duration!,
    ].join(' · ');

    return Card(
      child: InkWell(
        onTap: () => openRecipe(context, recipe),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm - 2),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.mdAll,
                child: NetworkThumb(
                  url: recipe.imageUrl,
                  width: 76,
                  height: 76,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: text.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (recipe.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.star,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            recipe.rating!.toStringAsFixed(1),
                            style: text.labelMedium,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (onToggleFavorite != null)
                IconButton(
                  tooltip: isFavorite
                      ? 'Favorilerden çıkar'
                      : 'Favorilere ekle',
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite
                        ? AppColors.favorite
                        : scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Görsel üzerinde duran yuvarlak favori butonu.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 1,
      child: IconButton(
        tooltip: isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
        onPressed: onPressed,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(isFavorite),
            color: isFavorite ? AppColors.favorite : AppColors.inkMuted,
          ),
        ),
      ),
    );
  }
}

class _GlassLabel extends StatelessWidget {
  const _GlassLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

void openRecipe(BuildContext context, Recipe recipe) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => RecipeDetayPage(recipe: recipe)),
  );
}
