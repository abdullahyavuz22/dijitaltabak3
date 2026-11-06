import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../pages/diyetler_page.dart';
import '../pages/soru_sorma_page.dart';
import '../pages/tarifler_page.dart';
import '../pages/videolu_tarifler_page.dart';
import '../pages/vki_hesaplama_page.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key, required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // (başlık, ikon, açılacak sayfa) — sayfa null ise "Yakında"
    final sections = <(String, List<(String, IconData, Widget?)>)>[
      (
        'Beslenme',
        [
          ('Tarifler', Icons.restaurant_menu_rounded, const TariflerPage()),
          (
            'Videolu Tarifler',
            Icons.play_circle_outline_rounded,
            const VideoluTariflerPage(),
          ),
          (
            'Diyetler',
            Icons.local_fire_department_outlined,
            const DiyetlerPage(),
          ),
          ('Beslenme Takvimi', Icons.calendar_month_outlined, null),
        ],
      ),
      (
        'Sağlık',
        [
          (
            'VKİ Hesaplama',
            Icons.monitor_weight_outlined,
            const VkiHesaplamaPage(),
          ),
          ('Diyetisyen Önerileri', Icons.medical_services_outlined, null),
          ('Soru Sor', Icons.forum_outlined, const SoruSormaPage()),
          ('Blog', Icons.article_outlined, null),
        ],
      ),
    ];

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Başlık
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: AppRadius.lgAll,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dijital Tabağım',
                          style: text.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Sağlıklı beslenme rehberin',
                          style: text.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                children: [
                  for (final (section, items) in sections) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        0,
                        AppSpacing.xs,
                      ),
                      child: Text(
                        section.toUpperCase(),
                        style: text.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    for (final (title, icon, page) in items)
                      ListTile(
                        leading: Icon(
                          icon,
                          color: page == null
                              ? scheme.onSurfaceVariant
                              : scheme.primary,
                        ),
                        title: Text(
                          title,
                          style: text.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: page == null
                                ? scheme.onSurfaceVariant
                                : scheme.onSurface,
                          ),
                        ),
                        trailing: page == null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.secondary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                                child: Text(
                                  'Yakında',
                                  style: text.labelSmall?.copyWith(
                                    color: const Color(0xFFB26A00),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          if (page != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => page),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$title yakında geliyor.'),
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ],
              ),
            ),

            const Divider(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: ListTile(
                leading: Icon(Icons.logout_rounded, color: scheme.error),
                title: Text(
                  'Çıkış Yap',
                  style: text.bodyLarge?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await onSignOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
