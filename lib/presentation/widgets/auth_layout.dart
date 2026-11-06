import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Giriş / Kayıt ekranlarının ortak iskeleti:
/// marka gradyanlı başlık + form kartı + alt bağlantı.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.tagline,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footerText,
    required this.footerAction,
    required this.onFooterTap,
    this.showBack = false,
  });

  final String tagline;
  final String title;
  final String subtitle;
  final Widget form;
  final String footerText;
  final String footerAction;
  final VoidCallback onFooterTap;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final headerHeight = MediaQuery.sizeOf(context).height * 0.38;

    return Scaffold(
      body: Stack(
        children: [
          // Gradyan başlık + dekoratif daireler
          Container(
            height: headerHeight,
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: Stack(
              children: [
                _circle(top: -60, right: -50, size: 220, alpha: 0.08),
                _circle(top: 70, left: -90, size: 200, alpha: 0.06),
                _circle(bottom: -40, right: 40, size: 110, alpha: 0.07),
              ],
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      if (showBack)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: 'Geri',
                            color: Colors.white,
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: AppColors.primary,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Dijital Tabağım',
                        style: text.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        tagline,
                        style: text.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl + 4),

                      // Form kartı
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: AppRadius.xlAll,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.xl + 4,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: text.headlineSmall),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              subtitle,
                              style: text.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            form,
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            footerText,
                            style: text.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: onFooterTap,
                            child: Text(footerAction),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required double alpha,
  }) => Positioned(
    top: top,
    left: left,
    right: right,
    bottom: bottom,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    ),
  );
}

/// Şifre alanı için göster/gizle butonu.
class PasswordToggle extends StatelessWidget {
  const PasswordToggle({
    super.key,
    required this.obscured,
    required this.onPressed,
  });

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: obscured ? 'Şifreyi göster' : 'Şifreyi gizle',
      onPressed: onPressed,
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
      ),
    );
  }
}
