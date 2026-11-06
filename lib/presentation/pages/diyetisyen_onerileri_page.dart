import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../domain/entities/recipe.dart';
import '../widgets/app_ui.dart';
import '../widgets/recipe_card.dart';

/// Tariflerdeki "Diyetisyen Değerlendirmesi" ve "Beslenme Önerisi"
/// metinlerini tek sayfada toplar.
class DiyetisyenOnerileriPage extends StatefulWidget {
  const DiyetisyenOnerileriPage({super.key, this.repository});

  /// Test / önizleme için değiştirilebilir veri kaynağı.
  final RecipeRepository? repository;

  @override
  State<DiyetisyenOnerileriPage> createState() =>
      _DiyetisyenOnerileriPageState();
}

class _DiyetisyenOnerileriPageState extends State<DiyetisyenOnerileriPage> {
  late final _repository = widget.repository ?? RecipeRepository();
  List<Recipe> _tarifler = [];
  bool _isLoading = true;
  String? _hata;
  String _kategori = 'Hepsi';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hata = null;
    });
    try {
      final list = await _repository.fetchRecipes();
      if (!mounted) return;
      setState(() {
        // Sadece diyetisyen notu veya beslenme önerisi olan tarifler
        _tarifler = list
            .where((r) => r.dietitianNote != null || r.nutritionAdvice != null)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[DiyetisyenOnerileri] Hata: $e');
      if (!mounted) return;
      setState(() {
        _hata = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final kategoriler = [
      'Hepsi',
      ...{
        for (final r in _tarifler)
          if (r.category != null && r.category!.isNotEmpty) r.category!,
      },
    ];
    final gosterilen = _kategori == 'Hepsi'
        ? _tarifler
        : _tarifler.where((r) => r.category == _kategori).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Diyetisyen Değerlendirmesi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hata != null
          ? ErrorState(
              message: 'Değerlendirmeler yüklenemedi.\n$_hata',
              onRetry: _load,
            )
          : _tarifler.isEmpty
          ? const EmptyState(
              icon: Icons.medical_services_outlined,
              title: 'Henüz değerlendirme yok',
              message:
                  'Tariflere diyetisyen değerlendirmesi eklendiğinde '
                  'burada görünecek.',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Tariflerimiz için diyetisyenlerimizin değerlendirmeleri '
                        've beslenme önerileri.',
                        style: text.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        itemCount: kategoriler.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.xs),
                        itemBuilder: (context, i) {
                          final k = kategoriler[i];
                          final secili = k == _kategori;
                          return ChoiceChip(
                            label: Text(k),
                            selected: secili,
                            onSelected: (_) => setState(() => _kategori = k),
                            labelStyle: text.labelLarge?.copyWith(
                              color: secili
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                            ),
                            side: BorderSide(
                              color: secili
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    sliver: SliverList.separated(
                      itemCount: gosterilen.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) =>
                          _OneriKarti(recipe: gosterilen[i]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _OneriKarti extends StatelessWidget {
  const _OneriKarti({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final meta = [
      if (recipe.category != null) recipe.category!,
      if (recipe.region != null) recipe.region!,
    ].join(' · ');

    return Card(
      child: InkWell(
        onTap: () => openRecipe(context, recipe),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tarif başlığı ───────────────────────────────
              Row(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.mdAll,
                    child: NetworkThumb(
                      url: recipe.imageUrl,
                      width: 56,
                      height: 56,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: text.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (meta.isNotEmpty)
                          Text(
                            meta,
                            style: text.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),

              // ── Diyetisyen değerlendirmesi ──────────────────
              if (recipe.dietitianNote != null) ...[
                const SizedBox(height: AppSpacing.md),
                _Bolum(
                  icon: Icons.medical_services_outlined,
                  color: scheme.primary,
                  baslik: 'Diyetisyen Değerlendirmesi',
                  metin: recipe.dietitianNote!,
                ),
              ],

              // ── Beslenme önerisi ────────────────────────────
              if (recipe.nutritionAdvice != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _Bolum(
                  icon: Icons.eco_outlined,
                  color: AppColors.warning,
                  baslik: 'Beslenme Önerisi',
                  metin: recipe.nutritionAdvice!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Renkli zeminli, ikonlu başlıklı metin bloğu.
class _Bolum extends StatelessWidget {
  const _Bolum({
    required this.icon,
    required this.color,
    required this.baslik,
    required this.metin,
  });

  final IconData icon;
  final Color color;
  final String baslik;
  final String metin;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(baslik, style: text.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(metin, style: text.bodyMedium),
        ],
      ),
    );
  }
}
