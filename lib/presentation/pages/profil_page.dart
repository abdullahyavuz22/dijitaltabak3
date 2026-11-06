import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/supabase_config.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/auth_repository.dart';
import '../viewmodels/favori_store.dart';
import '../widgets/app_ui.dart';
import '../widgets/kilo_takibi_karti.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? _kullanici;
  bool _isLoading = true;

  /// Aşağı çekip yenilemede kilo kartını da yeniden yüklemek için.
  int _yenileme = 0;

  @override
  void initState() {
    super.initState();
    _loadKullanici();
  }

  Future<void> _loadKullanici() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final response = await SupabaseConfig.client
          .from('kullanicilar')
          .select()
          .eq('id', userId)
          .single();
      if (mounted) {
        setState(() {
          _kullanici = response;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _adSoyad {
    if (_kullanici == null) return '';
    final ad = _kullanici!['ad'] ?? '';
    final soyad = _kullanici!['soyad'] ?? '';
    return '$ad $soyad'.trim();
  }

  String get _email {
    return _kullanici?['email'] ??
        SupabaseConfig.client.auth.currentUser?.email ??
        '';
  }

  String get _telefon {
    final t = _kullanici?['telefon'];
    return t is String ? t : '';
  }

  String get _initials {
    final parts = _adSoyad.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  /// Rol rozeti: (etiket, ikon, renk) — normal kullanıcıda null.
  (String, IconData, Color)? get _rolRozeti => switch (_kullanici?['role']) {
    'admin' => ('Yönetici', Icons.shield_outlined, AppColors.info),
    'diyetisyen' => (
      'Diyetisyen',
      Icons.medical_services_outlined,
      AppColors.warning,
    ),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final rozet = _rolRozeti;
    const bos = 'Bilgi girilmemiş';

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _yenileme++);
        await _loadKullanici();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          // ── Profil kartı ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: AppRadius.xlAll,
            ),
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 4,
                    ),
                  ),
                  child: Text(
                    _initials,
                    style: text.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _adSoyad.isNotEmpty ? _adSoyad : 'Kullanıcı',
                  style: text.titleLarge?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  _email,
                  style: text.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                if (rozet != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(rozet.$2, size: 16, color: rozet.$3),
                        const SizedBox(width: 6),
                        Text(
                          rozet.$1,
                          style: text.labelMedium?.copyWith(
                            color: rozet.$3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          KiloTakibiKarti(key: ValueKey(_yenileme)),

          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xxs),
            child: Text(
              'Kişisel Bilgiler',
              style: text.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Bilgi kartı ───────────────────────────────────
          Card(
            child: Column(
              children: [
                _BilgiSatiri(
                  icon: Icons.person_outline_rounded,
                  baslik: 'Ad Soyad',
                  deger: _adSoyad.isNotEmpty ? _adSoyad : bos,
                ),
                const Divider(indent: 68),
                _BilgiSatiri(
                  icon: Icons.email_outlined,
                  baslik: 'E-posta',
                  deger: _email.isNotEmpty ? _email : bos,
                ),
                const Divider(indent: 68),
                _BilgiSatiri(
                  icon: Icons.phone_outlined,
                  baslik: 'Telefon',
                  deger: _telefon.isNotEmpty ? _telefon : bos,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => _profiliDuzenle(context),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Profili Düzenle'),
          ),

          // ── Hesap ────────────────────────────────────────
          const SizedBox(height: AppSpacing.xxl),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xxs),
            child: Text(
              'Hesap',
              style: text.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs,
              ),
              leading: IconBadge(
                icon: Icons.person_remove_outlined,
                color: scheme.error,
                size: 40,
              ),
              title: Text(
                'Hesabı Sil',
                style: text.titleSmall?.copyWith(color: scheme.error),
              ),
              subtitle: Text(
                'Hesabın ve tüm verilerin kalıcı olarak silinir.',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
              onTap: () => _hesabiSil(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _hesabiSil(BuildContext context) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (_) => const _HesapSilDialog(),
    );
    if (onay != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    // Kök navigator, oturum kapanıp bu sayfa kaldırılsa da yaşamaya devam eder;
    // yükleniyor penceresini her durumda onunla kapatıyoruz.
    final rootNav = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    try {
      await AuthRepository().deleteAccount();
      FavoriStore.instance.clear();
      rootNav.pop();
      // Oturum kapandığı için AuthGate giriş ekranına yönlendirir.
      messenger.showSnackBar(const SnackBar(content: Text('Hesabın silindi.')));
    } catch (e) {
      debugPrint('[Profil] Hesap silme hatası: $e');
      rootNav.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Hesap silinemedi. Lütfen tekrar deneyin.'),
        ),
      );
    }
  }

  void _profiliDuzenle(BuildContext context) {
    final adController = TextEditingController(text: _kullanici?['ad'] ?? '');
    final soyadController = TextEditingController(
      text: _kullanici?['soyad'] ?? '',
    );
    final telefonController = TextEditingController(text: _telefon);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        bool kaydediliyor = false;
        String? hata;
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profili Düzenle',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: adController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Ad',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: soyadController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Soyad',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: telefonController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  if (hata != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AlertBanner(message: hata!),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  LoadingButton(
                    label: 'Kaydet',
                    icon: Icons.check_rounded,
                    loading: kaydediliyor,
                    onPressed: () async {
                      setModal(() {
                        kaydediliyor = true;
                        hata = null;
                      });
                      try {
                        final userId =
                            SupabaseConfig.client.auth.currentUser?.id;
                        if (userId != null) {
                          await SupabaseConfig.client
                              .from('kullanicilar')
                              .update({
                                'ad': adController.text.trim(),
                                'soyad': soyadController.text.trim(),
                                'telefon': telefonController.text.trim(),
                              })
                              .eq('id', userId);
                          if (mounted) {
                            await _loadKullanici();
                            if (ctx.mounted) Navigator.pop(ctx);
                          }
                        }
                      } catch (_) {
                        setModal(() {
                          kaydediliyor = false;
                          hata = 'Profil güncellenemedi. Tekrar deneyin.';
                        });
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BilgiSatiri extends StatelessWidget {
  const _BilgiSatiri({
    required this.icon,
    required this.baslik,
    required this.deger,
  });

  final IconData icon;
  final String baslik;
  final String deger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          IconBadge(icon: icon, size: 40),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik,
                  style: text.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(deger, style: text.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hesap silme onayı: geri alınamaz olduğu için "SİL" yazılması istenir.
class _HesapSilDialog extends StatefulWidget {
  const _HesapSilDialog();

  @override
  State<_HesapSilDialog> createState() => _HesapSilDialogState();
}

class _HesapSilDialogState extends State<_HesapSilDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _onaylandi {
    final v = _controller.text.trim().replaceAll('i', 'İ').toUpperCase();
    return v == 'SİL' || v == 'SIL';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: scheme.error, size: 32),
      title: const Text('Hesabı sil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu işlem geri alınamaz. Hesabınla birlikte şunlar kalıcı '
              'olarak silinir:',
              style: text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final m in const [
              'Profil bilgilerin',
              'Favori tariflerin',
              'Kilo kayıtların',
              'Gönderdiğin sorular',
            ])
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('•  $m', style: text.bodyMedium),
              ),
            const SizedBox(height: AppSpacing.md),
            Text('Onaylamak için SİL yazın:', style: text.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: 'SİL'),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            minimumSize: const Size(96, 44),
          ),
          onPressed: _onaylandi ? () => Navigator.pop(context, true) : null,
          child: const Text('Hesabı Sil'),
        ),
      ],
    );
  }
}
