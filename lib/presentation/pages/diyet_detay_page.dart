import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/entities/diyet.dart';
import '../viewmodels/favori_store.dart';
import '../widgets/app_ui.dart';

class DiyetDetayPage extends StatelessWidget {
  final Diyet diyet;

  const DiyetDetayPage({super.key, required this.diyet});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diyet Programı'),
        actions: [
          if (diyet.id != null)
            ListenableBuilder(
              listenable: FavoriStore.instance,
              builder: (context, _) {
                final store = FavoriStore.instance;
                final fav = store.isDiyetFavorite(diyet);
                return FavoriteIconButton(
                  isFavorite: fav,
                  onPressed: () => runFavoriteToggle(
                    context,
                    () => store.toggleDiyet(diyet),
                    wasFavorite: fav,
                  ),
                );
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          // ── Başlık kartı ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: AppRadius.xlAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    'DİYET PROGRAMI',
                    style: text.labelSmall?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  diyet.baslik,
                  style: text.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        diyet.diyetisyen,
                        style: text.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Özet ─────────────────────────────────────────
          if (diyet.kalori != null || diyet.sure != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (diyet.kalori != null)
                  Expanded(
                    child: StatTile(
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.warning,
                      label: 'Günlük Kalori',
                      value: '${diyet.kalori} kcal',
                    ),
                  ),
                if (diyet.kalori != null && diyet.sure != null)
                  const SizedBox(width: AppSpacing.sm),
                if (diyet.sure != null)
                  Expanded(
                    child: StatTile(
                      icon: Icons.schedule_rounded,
                      color: AppColors.info,
                      label: 'Süre',
                      value: diyet.sure!,
                    ),
                  ),
              ],
            ),
          ],

          // ── Açıklama ─────────────────────────────────────
          if (diyet.aciklama != null && diyet.aciklama!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            const SectionTitle(
              title: 'Program Detayı',
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(diyet.aciklama!, style: text.bodyLarge),
              ),
            ),
          ],

          // ── Diyetisyen ───────────────────────────────────
          const SizedBox(height: AppSpacing.xl),
          const SectionTitle(
            title: 'Diyetisyen',
            icon: Icons.medical_services_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: scheme.primary.withValues(alpha: 0.12),
                    child: Icon(
                      Icons.person_rounded,
                      color: scheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(diyet.diyetisyen, style: text.titleMedium),
                        Text(
                          'Programı hazırlayan uzman',
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const AlertBanner(
            isError: false,
            message:
                'Bu program genel bilgilendirme amaçlıdır. Sağlık '
                'durumunuza özel plan için diyetisyeninize danışın.',
          ),
        ],
      ),
    );
  }
}
