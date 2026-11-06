import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/supabase_config.dart';
import '../../core/theme/app_tokens.dart';
import '../widgets/app_ui.dart';

class VkiHesaplamaPage extends StatefulWidget {
  const VkiHesaplamaPage({super.key});

  @override
  State<VkiHesaplamaPage> createState() => _VkiHesaplamaPageState();
}

/// VKİ aralığı: etiket, renk, açıklama ve üst sınır.
typedef _Aralik = ({String ad, Color renk, String aciklama, double ust});

const List<_Aralik> _araliklar = [
  (
    ad: 'Zayıf',
    renk: AppColors.info,
    aciklama:
        'İdeal kilonun altındasınız. Dengeli ve yeterli beslenmeye '
        'özen gösterin.',
    ust: 18.5,
  ),
  (
    ad: 'Normal',
    renk: AppColors.success,
    aciklama: 'Tebrikler! Kilonuz boyunuza göre sağlıklı aralıkta.',
    ust: 24.9,
  ),
  (
    ad: 'Fazla Kilolu',
    renk: AppColors.warning,
    aciklama:
        'İdeal kilonun biraz üzerindesiniz. Düzenli egzersiz ve '
        'dengeli beslenme faydalı olabilir.',
    ust: 29.9,
  ),
  (
    ad: 'Obez',
    renk: AppColors.danger,
    aciklama:
        'Sağlığınız için bir uzmana veya diyetisyene danışmanızı '
        'öneririz.',
    ust: double.infinity,
  ),
];

class _VkiHesaplamaPageState extends State<VkiHesaplamaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _boyController = TextEditingController();
  final TextEditingController _kiloController = TextEditingController();
  double? _vki;
  bool _isSaving = false;
  bool _kaydedildi = false;

  @override
  void dispose() {
    _boyController.dispose();
    _kiloController.dispose();
    super.dispose();
  }

  double? _sayi(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  Future<void> _hesapla() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final boy = _sayi(_boyController.text)!;
    final kilo = _sayi(_kiloController.text)!;

    final sonuc = kilo / ((boy / 100) * (boy / 100));
    setState(() {
      _vki = sonuc;
      _isSaving = true;
      _kaydedildi = false;
    });

    try {
      await SupabaseConfig.client.from('vki_kayitlari').insert({
        'boy': boy,
        'kilo': kilo,
        'vki': double.parse(sonuc.toStringAsFixed(2)),
        'durum': _vkiDurumu(sonuc),
      });
      _kaydedildi = true;
    } catch (_) {
      // Kayıt başarısız olsa bile sonucu göster
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Veritabanına yazılan durum metni (mevcut kayıtlarla uyumlu kalsın).
  String _vkiDurumu(double vki) {
    if (vki < 18.5) return "Zayıf 🟡";
    if (vki < 24.9) return "Normal 🟢";
    if (vki < 29.9) return "Fazla Kilolu 🟠";
    return "Obez 🔴";
  }

  _Aralik _aralik(double vki) => _araliklar.firstWhere((a) => vki < a.ust);

  String? _dogrula(String? v, String alan, double min, double max) {
    final n = _sayi(v ?? '');
    if (n == null) return '$alan girin';
    if (n < min || n > max) return 'Geçerli bir değer girin';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('VKİ Hesaplama')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          Text(
            'Vücut Kitle İndeksi, kilonuzun boyunuza göre sağlıklı '
            'aralıkta olup olmadığını gösterir.',
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _boyController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Boy',
                              suffixText: 'cm',
                              prefixIcon: Icon(Icons.height_rounded),
                            ),
                            validator: (v) => _dogrula(v, 'Boy', 50, 260),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextFormField(
                            controller: _kiloController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!_isSaving) _hesapla();
                            },
                            decoration: const InputDecoration(
                              labelText: 'Kilo',
                              suffixText: 'kg',
                              prefixIcon: Icon(Icons.monitor_weight_outlined),
                            ),
                            validator: (v) => _dogrula(v, 'Kilo', 10, 400),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    LoadingButton(
                      label: 'Hesapla',
                      icon: Icons.calculate_outlined,
                      loading: _isSaving,
                      onPressed: _hesapla,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _vki == null
                ? _AralikTablosu(key: const ValueKey('tablo'))
                : _SonucKarti(
                    key: ValueKey(_vki),
                    vki: _vki!,
                    aralik: _aralik(_vki!),
                    kaydedildi: _kaydedildi,
                    kaydediliyor: _isSaving,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SonucKarti extends StatelessWidget {
  const _SonucKarti({
    super.key,
    required this.vki,
    required this.aralik,
    required this.kaydedildi,
    required this.kaydediliyor,
  });

  final double vki;
  final _Aralik aralik;
  final bool kaydedildi;
  final bool kaydediliyor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Gösterge: 15–35 aralığına göre konum
    final konum = ((vki - 15) / 20).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sonucunuz',
              style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  vki.toStringAsFixed(1),
                  style: text.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: aralik.renk,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InfoPill(
                    icon: Icons.circle,
                    label: aralik.ad,
                    color: aralik.renk,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Renkli gösterge çubuğu
            LayoutBuilder(
              builder: (context, c) => Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Row(
                      children: [
                        for (final (flex, renk) in [
                          // 15–35 ölçeğinde aralık genişlikleri (×10)
                          (35, AppColors.info),
                          (65, AppColors.success),
                          (50, AppColors.warning),
                          (50, AppColors.danger),
                        ])
                          Expanded(
                            flex: flex,
                            child: Container(height: 10, color: renk),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: konum * c.maxWidth - 9,
                    top: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: aralik.renk, width: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final s in ['15', '35+'])
                  Text(
                    s,
                    style: text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(aralik.aciklama, style: text.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  kaydediliyor
                      ? Icons.sync_rounded
                      : kaydedildi
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  kaydediliyor
                      ? 'Kaydediliyor...'
                      : kaydedildi
                      ? 'Sonuç kaydedildi'
                      : 'Sonuç kaydedilemedi',
                  style: text.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AralikTablosu extends StatelessWidget {
  const _AralikTablosu({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const sinirlar = ['< 18.5', '18.5 – 24.9', '25 – 29.9', '≥ 30'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          children: [
            for (var i = 0; i < _araliklar.length; i++)
              ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 6,
                  backgroundColor: _araliklar[i].renk,
                ),
                title: Text(_araliklar[i].ad, style: text.titleSmall),
                trailing: Text(sinirlar[i], style: text.labelLarge),
              ),
          ],
        ),
      ),
    );
  }
}
