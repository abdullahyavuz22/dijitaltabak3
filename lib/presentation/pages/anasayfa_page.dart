import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../widgets/app_ui.dart';
import '../widgets/recipe_card.dart';
import 'diyetler_page.dart';
import 'soru_sorma_page.dart';
import 'videolu_tarifler_page.dart';
import 'vki_hesaplama_page.dart';
import '../../domain/entities/recipe.dart';

typedef AddRecipeCallback =
    Future<void> Function({
      required String name,
      String? imageUrl,
      String? category,
      String? duration,
      double? rating,
    });

class AnasayfaPage extends StatefulWidget {
  final List<Recipe> recipes;
  final Set<String> favorites;
  final void Function(Recipe recipe) onToggleFavorite;

  /// Tarif ekleme yetkisi (sadece admin rolü).
  final bool isAdmin;
  final AddRecipeCallback onAddRecipe;

  const AnasayfaPage({
    super.key,
    required this.recipes,
    required this.favorites,
    required this.onToggleFavorite,
    required this.isAdmin,
    required this.onAddRecipe,
  });

  @override
  State<AnasayfaPage> createState() => _AnasayfaPageState();
}

class _AnasayfaPageState extends State<AnasayfaPage> {
  String selectedCategory = 'Hepsi';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final filtered = selectedCategory == 'Hepsi'
        ? widget.recipes
        : widget.recipes.where((r) => r.category == selectedCategory).toList();

    final categories = [
      'Hepsi',
      ...{
        for (final r in widget.recipes)
          if (r.category != null && r.category!.isNotEmpty) r.category!,
      },
    ];

    return CustomScrollView(
      slivers: [
        // ── Karşılama kartı ─────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: _HeroCard(recipeCount: widget.recipes.length),
          ),
        ),

        // ── Hızlı erişim ────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                for (final (label, icon, color, page) in [
                  (
                    'VKİ',
                    Icons.monitor_weight_outlined,
                    AppColors.info,
                    const VkiHesaplamaPage() as Widget,
                  ),
                  (
                    'Diyetler',
                    Icons.local_fire_department_outlined,
                    AppColors.warning,
                    const DiyetlerPage(),
                  ),
                  (
                    'Videolar',
                    Icons.play_circle_outline_rounded,
                    AppColors.danger,
                    const VideoluTariflerPage(),
                  ),
                  (
                    'Soru Sor',
                    Icons.forum_outlined,
                    scheme.primary,
                    const SoruSormaPage(),
                  ),
                ])
                  Expanded(
                    child: _QuickAction(
                      label: label,
                      icon: icon,
                      color: color,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => page),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Kategoriler ─────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          sliver: SliverToBoxAdapter(
            child: SectionTitle(
              title: 'Tarifler',
              trailing: widget.isAdmin
                  ? FilledButton.tonalIcon(
                      onPressed: () => _showAddRecipeDialog(context),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Tarif Ekle'),
                    )
                  : null,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, i) {
                final cat = categories[i];
                final isSelected = cat == selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => setState(() => selectedCategory = cat),
                  labelStyle: text.labelLarge?.copyWith(
                    color: isSelected ? scheme.onPrimary : scheme.onSurface,
                  ),
                  side: BorderSide(
                    color: isSelected ? scheme.primary : scheme.outlineVariant,
                  ),
                );
              },
            ),
          ),
        ),

        // ── Tarif kartları ──────────────────────────────────
        if (filtered.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.restaurant_menu_rounded,
              title: 'Tarif bulunamadı',
              message: 'Bu kategoride henüz tarif yok.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final recipe = filtered[i];
                return RecipeCard(
                  recipe: recipe,
                  isFavorite: widget.favorites.contains(recipe.id),
                  onToggleFavorite: () => widget.onToggleFavorite(recipe),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _showAddRecipeDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final imageUrlController = TextEditingController();
    final durationController = TextEditingController();
    final ratingController = TextEditingController();
    bool isSaving = false;
    String? error;

    String? orNull(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Yeni Tarif'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Tarif Adı *',
                          prefixIcon: Icon(Icons.restaurant_rounded),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Tarif adı boş olamaz'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: categoryController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: imageUrlController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'Görsel URL',
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: durationController,
                              decoration: const InputDecoration(
                                labelText: 'Süre',
                                hintText: '20 dk',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: ratingController,
                              decoration: const InputDecoration(
                                labelText: 'Puan',
                                hintText: '0-5',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      if (error != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        AlertBanner(message: error!),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('İptal'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(96, 44),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() {
                            isSaving = true;
                            error = null;
                          });
                          try {
                            await widget.onAddRecipe(
                              name: nameController.text.trim(),
                              category: orNull(categoryController),
                              imageUrl: orNull(imageUrlController),
                              duration: orNull(durationController),
                              rating: double.tryParse(
                                ratingController.text.trim().replaceAll(
                                  ',',
                                  '.',
                                ),
                              ),
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } catch (e) {
                            setDialogState(() {
                              isSaving = false;
                              error =
                                  'Ekleme başarısız (yetkiniz olmayabilir).';
                            });
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.recipeCount});

  final int recipeCount;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 6) return 'İyi geceler';
    if (h < 12) return 'Günaydın';
    if (h < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.xlAll,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            bottom: -18,
            child: Icon(
              Icons.eco_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: text.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Bugün ne pişiriyoruz?',
                style: text.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$recipeCount sağlıklı tarif seni bekliyor',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          children: [
            IconBadge(icon: icon, color: color, size: 54),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
