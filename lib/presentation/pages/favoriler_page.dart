import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/entities/recipe.dart';
import '../viewmodels/favori_store.dart';
import '../widgets/app_ui.dart';
import '../widgets/recipe_card.dart';
import 'diyetler_page.dart';
import 'videolu_tarifler_page.dart';

/// Favoriler sekmesi: Tarifler / Diyetler / Videolar.
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
    final store = FavoriStore.instance;
    final favRecipes = recipes.where((r) => favorites.contains(r.id)).toList();

    return DefaultTabController(
      length: 3,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => Column(
          children: [
            TabBar(
              tabs: [
                _tab('Tarifler', favRecipes.length),
                _tab('Diyetler', store.diyetler.length),
                _tab('Videolar', store.videolar.length),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _TariflerTab(
                    recipes: favRecipes,
                    onToggleFavorite: onToggleFavorite,
                    onExplore: onExplore,
                  ),
                  _DiyetlerTab(store: store),
                  _VideolarTab(store: store),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Tab _tab(String label, int count) =>
      Tab(text: count > 0 ? '$label ($count)' : label);
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

class _DiyetlerTab extends StatelessWidget {
  const _DiyetlerTab({required this.store});

  final FavoriStore store;

  @override
  Widget build(BuildContext context) {
    final diyetler = store.diyetler;
    return RefreshIndicator(
      onRefresh: store.load,
      child: diyetler.isEmpty
          ? _ScrollableEmpty(
              child: EmptyState(
                icon: Icons.local_fire_department_outlined,
                title: 'Favori diyetin yok',
                message:
                    'Diyet programlarındaki kalp ikonuyla\n'
                    'beğendiklerini kaydedebilirsin.',
                action: FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DiyetlerPage()),
                  ),
                  icon: const Icon(Icons.local_fire_department_rounded),
                  label: const Text('Diyetlere Göz At'),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              itemCount: diyetler.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final d = diyetler[i];
                return DiyetKarti(
                  diyet: d,
                  isFavorite: true,
                  onToggleFavorite: () => runFavoriteToggle(
                    context,
                    () => store.toggleDiyet(d),
                    wasFavorite: true,
                  ),
                );
              },
            ),
    );
  }
}

class _VideolarTab extends StatelessWidget {
  const _VideolarTab({required this.store});

  final FavoriStore store;

  @override
  Widget build(BuildContext context) {
    final videolar = store.videolar;
    return RefreshIndicator(
      onRefresh: store.load,
      child: videolar.isEmpty
          ? _ScrollableEmpty(
              child: EmptyState(
                icon: Icons.video_library_outlined,
                title: 'Favori videon yok',
                message:
                    'Videolu tariflerdeki kalp ikonuyla\n'
                    'izlemek istediklerini kaydedebilirsin.',
                action: FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VideoluTariflerPage(),
                    ),
                  ),
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: const Text('Videolara Göz At'),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              itemCount: videolar.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final v = videolar[i];
                return VideoKart(
                  video: v,
                  isFavorite: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          VideoluTariflerPage(initialVideoId: v.videoId),
                    ),
                  ),
                  onToggleFavorite: () => runFavoriteToggle(
                    context,
                    () => store.toggleVideo(v),
                    wasFavorite: true,
                  ),
                );
              },
            ),
    );
  }
}

/// Boş durumda da aşağı çekip yenilemeyi mümkün kılar.
class _ScrollableEmpty extends StatelessWidget {
  const _ScrollableEmpty({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: child,
        ),
      ),
    );
  }
}
