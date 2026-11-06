import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/entities/recipe.dart';
import '../widgets/app_ui.dart';

class RecipeDetayPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetayPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final stats = <Widget>[
      if (recipe.rating != null)
        StatTile(
          icon: Icons.star_rounded,
          color: AppColors.star,
          label: 'Puan',
          value: recipe.rating!.toStringAsFixed(1),
        ),
      if (recipe.duration != null)
        StatTile(
          icon: Icons.schedule_rounded,
          label: 'Süre',
          value: recipe.duration!,
        ),
      if (recipe.category != null)
        StatTile(
          icon: Icons.category_outlined,
          color: AppColors.info,
          label: 'Kategori',
          value: recipe.category!,
        ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: scheme.surface,
            leading: const Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: _CircleBack(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkThumb(url: recipe.imageUrl),
                  // Alt kısımda yumuşak karartma
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, Colors.transparent],
                        stops: [0, 0.35],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl + 4),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, style: text.headlineSmall),
                  if (stats.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        for (var i = 0; i < stats.length; i++) ...[
                          if (i > 0) const SizedBox(width: AppSpacing.sm),
                          Expanded(child: stats[i]),
                        ],
                      ],
                    ),
                  ],

                  // Malzemeler
                  if (recipe.ingredients.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    SectionTitle(
                      title: 'Malzemeler',
                      icon: Icons.shopping_basket_outlined,
                      trailing: Text(
                        '${recipe.ingredients.length} adet',
                        style: text.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: Column(
                          children: [
                            for (final item in recipe.ingredients)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: scheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(item, style: text.bodyLarge),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Yapılış
                  if (recipe.instructions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const SectionTitle(
                      title: 'Yapılışı',
                      icon: Icons.menu_book_outlined,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (var i = 0; i < recipe.instructions.length; i++)
                      _AdimSatiri(
                        index: i + 1,
                        text: recipe.instructions[i],
                        isLast: i == recipe.instructions.length - 1,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Zaman çizelgesi görünümünde numaralı adım.
class _AdimSatiri extends StatelessWidget {
  const _AdimSatiri({
    required this.index,
    required this.text,
    required this.isLast,
  });

  final int index;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: scheme.primary.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 5,
                bottom: isLast ? 0 : AppSpacing.lg,
              ),
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: 'Geri',
        color: AppColors.ink,
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.maybePop(context),
      ),
    );
  }
}
