import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/entities/recipe.dart';
import '../widgets/app_ui.dart';

class RecipeDetayPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetayPage({super.key, required this.recipe});

  /// "40 dakika (pirinç ıslatma dahil)" → ("40 dakika", "pirinç ıslatma dahil")
  static (String, String?) _bol(String s) {
    final m = RegExp(r'^(.*?)\s*\((.*)\)\s*$').firstMatch(s);
    return m == null ? (s, null) : (m.group(1)!, m.group(2));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final hazirlik = recipe.prepTime == null ? null : _bol(recipe.prepTime!);
    final pisirme = recipe.cookTime == null ? null : _bol(recipe.cookTime!);
    final sureNotlari = [
      if (hazirlik?.$2 != null) 'Hazırlık: ${hazirlik!.$2}',
      if (pisirme?.$2 != null) 'Pişirme: ${pisirme!.$2}',
    ];

    final stats = <Widget>[
      if (hazirlik != null)
        StatTile(
          icon: Icons.timer_outlined,
          label: 'Hazırlık',
          value: hazirlik.$1,
        )
      else if (recipe.duration != null)
        StatTile(
          icon: Icons.schedule_rounded,
          label: 'Süre',
          value: recipe.duration!,
        ),
      if (pisirme != null)
        StatTile(
          icon: Icons.local_fire_department_outlined,
          color: AppColors.warning,
          label: 'Pişirme',
          value: pisirme.$1,
        ),
      if (recipe.servings != null)
        StatTile(
          icon: Icons.people_outline_rounded,
          color: AppColors.info,
          label: 'Porsiyon',
          value: recipe.servings!,
        )
      else if (recipe.rating != null)
        StatTile(
          icon: Icons.star_rounded,
          color: AppColors.star,
          label: 'Puan',
          value: recipe.rating!.toStringAsFixed(1),
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
                  // Üst kısımda yumuşak karartma (geri butonu okunsun)
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
                  // ── Başlık ───────────────────────────────────
                  if (recipe.category != null) ...[
                    InfoPill(
                      icon: Icons.restaurant_menu_rounded,
                      label: recipe.category!,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  Text(recipe.name, style: text.headlineSmall),
                  if (recipe.region != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            recipe.region!,
                            style: text.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (recipe.description != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(recipe.description!, style: text.bodyLarge),
                  ],

                  // ── Özet ─────────────────────────────────────
                  if (stats.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < stats.length; i++) ...[
                            if (i > 0) const SizedBox(width: AppSpacing.sm),
                            Expanded(child: stats[i]),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (sureNotlari.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      sureNotlari.join(' · '),
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  // ── Malzemeler ───────────────────────────────
                  if (recipe.ingredients.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    SectionTitle(
                      title: 'Malzemeler',
                      icon: Icons.shopping_basket_outlined,
                      trailing: Text(
                        '${recipe.ingredientCount} malzeme',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final (i, item) in recipe.ingredients.indexed)
                              Recipe.isIngredientHeader(item)
                                  ? Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        AppSpacing.md,
                                        i == 0 ? AppSpacing.xs : AppSpacing.md,
                                        AppSpacing.md,
                                        AppSpacing.xxs,
                                      ),
                                      child: Text(
                                        item.trimRight().replaceAll(
                                          RegExp(r':$'),
                                          '',
                                        ),
                                        style: text.titleSmall?.copyWith(
                                          color: scheme.primary,
                                        ),
                                      ),
                                    )
                                  : _MalzemeSatiri(item),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── Hazırlanışı ──────────────────────────────
                  if (recipe.instructions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const SectionTitle(
                      title: 'Hazırlanışı',
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

                  // ── Not ──────────────────────────────────────
                  if (recipe.tips != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _VurguKart(
                      icon: Icons.lightbulb_outline_rounded,
                      color: AppColors.warning,
                      baslik: 'Not',
                      metin: recipe.tips!,
                    ),
                  ],

                  // ── Besin değerleri ──────────────────────────
                  if (recipe.nutrition.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const SectionTitle(
                      title: 'Besin Öğesi Bileşimi',
                      icon: Icons.analytics_outlined,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _BesinTablosu(
                      porsiyon: recipe.nutrition,
                      toplam: recipe.nutritionTotal,
                      servings: recipe.servings,
                    ),
                  ],
                  // Beslenme önerisi ve diyetisyen değerlendirmesi burada
                  // gösterilmez; Diyetisyen Değerlendirmesi sayfasında yer alır.
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MalzemeSatiri extends StatelessWidget {
  const _MalzemeSatiri(this.item);

  final String item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
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
            child: Text(item, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

/// İkonlu, renkli zeminli bilgi kartı (Not).
class _VurguKart extends StatelessWidget {
  const _VurguKart({
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: text.titleSmall),
                const SizedBox(height: 2),
                Text(metin, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 1 porsiyon / tüm tarif besin değerleri tablosu.
class _BesinTablosu extends StatefulWidget {
  const _BesinTablosu({
    required this.porsiyon,
    required this.toplam,
    this.servings,
  });

  final List<BesinOgesi> porsiyon;
  final List<BesinOgesi> toplam;
  final String? servings;

  @override
  State<_BesinTablosu> createState() => _BesinTablosuState();
}

class _BesinTablosuState extends State<_BesinTablosu> {
  bool _toplam = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final rows = _toplam ? widget.toplam : widget.porsiyon;
    final porsiyonSayisi = RegExp(r'\d+').stringMatch(widget.servings ?? '');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.toplam.isNotEmpty) ...[
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  const ButtonSegment(value: false, label: Text('1 Porsiyon')),
                  ButtonSegment(
                    value: true,
                    label: Text(
                      porsiyonSayisi == null
                          ? 'Tüm Tarif'
                          : 'Tüm Tarif ($porsiyonSayisi)',
                    ),
                  ),
                ],
                selected: {_toplam},
                onSelectionChanged: (s) => setState(() => _toplam = s.first),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            for (final (i, b) in rows.indexed) ...[
              if (i > 0) const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(child: Text(b.ad, style: text.bodyLarge)),
                    Text(b.miktar, style: text.titleSmall),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Değerler yaklaşıktır; malzemelerin çiğ ağırlıkları üzerinden '
              'hesaplanmıştır ve kullanılan ürüne göre değişebilir.',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
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
