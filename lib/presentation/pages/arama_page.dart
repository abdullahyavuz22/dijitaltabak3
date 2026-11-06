import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/entities/recipe.dart';
import '../widgets/app_ui.dart';
import '../widgets/recipe_card.dart';

/// Tarif adı, kategori veya malzemeye göre arama.
class AramaPage extends StatefulWidget {
  const AramaPage({
    super.key,
    required this.recipes,
    required this.favorites,
    required this.onToggleFavorite,
  });

  final List<Recipe> recipes;
  final Set<String> favorites;
  final void Function(Recipe recipe) onToggleFavorite;

  @override
  State<AramaPage> createState() => _AramaPageState();
}

class _AramaPageState extends State<AramaPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Türkçe büyük/küçük harf duyarsız karşılaştırma için normalleştirir.
  static String _norm(String s) =>
      s.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

  List<Recipe> get _results {
    final q = _norm(_query.trim());
    if (q.isEmpty) return widget.recipes;
    return widget.recipes.where((r) {
      return _norm(r.name).contains(q) ||
          _norm(r.category ?? '').contains(q) ||
          r.ingredients.any((i) => _norm(i).contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final results = _results;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: SearchBar(
            controller: _controller,
            hintText: 'Tarif, kategori veya malzeme ara',
            leading: Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
            trailing: [
              if (_query.isNotEmpty)
                IconButton(
                  tooltip: 'Temizle',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _query = '');
                  },
                ),
            ],
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _query.isEmpty
                  ? 'Tüm tarifler (${results.length})'
                  : '${results.length} sonuç',
              style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Expanded(
          child: results.isEmpty
              ? EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Sonuç bulunamadı',
                  message:
                      '"$_query" için eşleşen tarif yok.\n'
                      'Farklı bir kelime deneyin.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: results.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final r = results[i];
                    return RecipeTile(
                      recipe: r,
                      isFavorite: widget.favorites.contains(r.id),
                      onToggleFavorite: () => widget.onToggleFavorite(r),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
