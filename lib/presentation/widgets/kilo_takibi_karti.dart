import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/kilo_repository.dart';
import '../../domain/entities/kilo_kaydi.dart';
import 'app_ui.dart';
import 'kilo_grafik.dart';

/// Profil sayfasındaki kilo takibi: güncel kilo, değişim, grafik ve kayıtlar.
class KiloTakibiKarti extends StatefulWidget {
  const KiloTakibiKarti({super.key, this.repository});

  /// Test / önizleme için değiştirilebilir veri kaynağı.
  final KiloRepository? repository;

  @override
  State<KiloTakibiKarti> createState() => _KiloTakibiKartiState();
}

class _KiloTakibiKartiState extends State<KiloTakibiKarti> {
  late final _repository = widget.repository ?? KiloRepository();
  List<KiloKaydi> _kayitlar = [];
  bool _isLoading = true;
  bool _hata = false;
  bool _tumu = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hata = false;
    });
    try {
      final list = await _repository.fetch();
      if (mounted) setState(() => _kayitlar = list);
    } catch (e) {
      debugPrint('[Kilo] Yükleme hatası: $e');
      if (mounted) setState(() => _hata = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sil(KiloKaydi k) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kaydı sil'),
        content: Text(
          '${uzunTarih(k.tarih)} tarihli ${kgMetni(k.kilo)} kaydı silinsin mi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (onay != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _repository.delete(k.id);
      if (mounted) setState(() => _kayitlar.remove(k));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Kayıt silinemedi.')),
      );
    }
  }

  Future<void> _ekle() async {
    final eklendi = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _KiloEkleSheet(
        repository: _repository,
        sonKilo: _kayitlar.isEmpty ? null : _kayitlar.last.kilo,
      ),
    );
    if (eklendi == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconBadge(icon: Icons.monitor_weight_outlined, size: 40),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Kilo Takibi', style: text.titleMedium)),
                FilledButton.tonalIcon(
                  onPressed: _isLoading ? null : _ekle,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Kilo Ekle'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_isLoading)
              const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hata)
              _Bilgi(
                icon: Icons.cloud_off_rounded,
                metin: 'Kilo kayıtları yüklenemedi.',
                aksiyon: TextButton(
                  onPressed: _load,
                  child: const Text('Tekrar Dene'),
                ),
              )
            else if (_kayitlar.isEmpty)
              const _Bilgi(
                icon: Icons.show_chart_rounded,
                metin:
                    'Henüz kilo kaydın yok. İlk kilonu ekle, '
                    'değişimini burada grafikle takip et.',
              )
            else
              ..._icerik(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _icerik(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final ilk = _kayitlar.first;
    final son = _kayitlar.last;
    final fark = son.kilo - ilk.kilo;
    final kilolar = _kayitlar.map((e) => e.kilo);
    final gosterilen = _kayitlar.reversed.take(_tumu ? _kayitlar.length : 4);

    return [
      // ── Özet ────────────────────────────────────────────
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            son.kilo.toStringAsFixed(1),
            style: text.displaySmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'kg',
              style: text.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const Spacer(),
          if (_kayitlar.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _FarkEtiketi(fark: fark),
            ),
        ],
      ),
      Text(
        _kayitlar.length > 1
            ? 'Son ölçüm ${uzunTarih(son.tarih)} · İlk kayıt ${uzunTarih(ilk.tarih)}'
            : 'Son ölçüm ${uzunTarih(son.tarih)}',
        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      const SizedBox(height: AppSpacing.md),

      // ── Grafik ──────────────────────────────────────────
      if (_kayitlar.length >= 2) ...[
        KiloGrafik(kayitlar: _kayitlar),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _MiniStat(etiket: 'Başlangıç', deger: kgMetni(ilk.kilo)),
            ),
            Expanded(
              child: _MiniStat(
                etiket: 'En düşük',
                deger: kgMetni(kilolar.reduce(math.min)),
              ),
            ),
            Expanded(
              child: _MiniStat(
                etiket: 'En yüksek',
                deger: kgMetni(kilolar.reduce(math.max)),
              ),
            ),
          ],
        ),
      ] else
        const _Bilgi(
          icon: Icons.insights_rounded,
          metin: 'Grafiğin oluşması için en az 2 kayıt gerekli.',
        ),

      // ── Kayıtlar (tablo görünümü) ──────────────────────
      const SizedBox(height: AppSpacing.md),
      const Divider(),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'Kayıtlar',
        style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
      ),
      for (final k in gosterilen)
        _KayitSatiri(kayit: k, onceki: _onceki(k), onSil: () => _sil(k)),
      if (_kayitlar.length > 4)
        Center(
          child: TextButton(
            onPressed: () => setState(() => _tumu = !_tumu),
            child: Text(
              _tumu ? 'Daha az göster' : 'Tümünü göster (${_kayitlar.length})',
            ),
          ),
        ),
    ];
  }

  KiloKaydi? _onceki(KiloKaydi k) {
    final i = _kayitlar.indexOf(k);
    return i > 0 ? _kayitlar[i - 1] : null;
  }
}

/// Değişim etiketi: ok + kg (renk yargısız — kilo artışı/azalışı
/// herkes için iyi ya da kötü değildir).
class _FarkEtiketi extends StatelessWidget {
  const _FarkEtiketi({required this.fark});

  final double fark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sabit = fark.abs() < 0.05;
    final icon = sabit
        ? Icons.trending_flat_rounded
        : fark < 0
        ? Icons.trending_down_rounded
        : Icons.trending_up_rounded;
    final metin = sabit
        ? 'Değişim yok'
        : '${fark > 0 ? '+' : '−'}${fark.abs().toStringAsFixed(1)} kg';
    return InfoPill(icon: icon, label: metin, color: scheme.onSurfaceVariant);
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.etiket, required this.deger});

  final String etiket;
  final String deger;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(deger, style: text.titleSmall),
        Text(
          etiket,
          style: text.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _KayitSatiri extends StatelessWidget {
  const _KayitSatiri({
    required this.kayit,
    required this.onceki,
    required this.onSil,
  });

  final KiloKaydi kayit;
  final KiloKaydi? onceki;
  final VoidCallback onSil;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fark = onceki == null ? null : kayit.kilo - onceki!.kilo;

    return Row(
      children: [
        Expanded(child: Text(uzunTarih(kayit.tarih), style: text.bodyMedium)),
        if (fark != null && fark.abs() >= 0.05)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Text(
              '${fark > 0 ? '+' : '−'}${fark.abs().toStringAsFixed(1)}',
              style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        Text(kgMetni(kayit.kilo), style: text.titleSmall),
        IconButton(
          tooltip: 'Kaydı sil',
          visualDensity: VisualDensity.compact,
          icon: Icon(
            Icons.delete_outline_rounded,
            size: 20,
            color: scheme.onSurfaceVariant,
          ),
          onPressed: onSil,
        ),
      ],
    );
  }
}

class _Bilgi extends StatelessWidget {
  const _Bilgi({required this.icon, required this.metin, this.aksiyon});

  final IconData icon;
  final String metin;
  final Widget? aksiyon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(metin, style: Theme.of(context).textTheme.bodyMedium),
          ),
          ?aksiyon,
        ],
      ),
    );
  }
}

/// Yeni kilo kaydı alt sayfası.
class _KiloEkleSheet extends StatefulWidget {
  const _KiloEkleSheet({required this.repository, this.sonKilo});

  final KiloRepository repository;
  final double? sonKilo;

  @override
  State<_KiloEkleSheet> createState() => _KiloEkleSheetState();
}

class _KiloEkleSheetState extends State<_KiloEkleSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _kilo = TextEditingController(
    text: widget.sonKilo?.toStringAsFixed(1) ?? '',
  );
  DateTime _tarih = DateTime.now();
  bool _saving = false;
  String? _hata;

  @override
  void dispose() {
    _kilo.dispose();
    super.dispose();
  }

  double? get _deger => double.tryParse(_kilo.text.trim().replaceAll(',', '.'));

  Future<void> _tarihSec() async {
    final now = DateTime.now();
    final secilen = await showDatePicker(
      context: context,
      initialDate: _tarih,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'Ölçüm tarihi',
      cancelText: 'Vazgeç',
      confirmText: 'Seç',
    );
    if (secilen != null) {
      setState(() {
        // Bugün seçildiyse şu anki saati koru (aynı gün sıralaması için)
        final bugun =
            secilen.year == now.year &&
            secilen.month == now.month &&
            secilen.day == now.day;
        _tarih = bugun
            ? now
            : DateTime(secilen.year, secilen.month, secilen.day, 12);
      });
    }
  }

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _hata = null;
    });
    try {
      await widget.repository.add(_deger!, _tarih);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('[Kilo] Ekleme hatası: $e');
      if (mounted) {
        setState(() {
          _saving = false;
          _hata = 'Kayıt eklenemedi. Tekrar deneyin.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kilo Ekle', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _kilo,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Kilo',
                suffixText: 'kg',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
              validator: (_) {
                final v = _deger;
                if (v == null) return 'Kilonuzu girin';
                if (v < 20 || v > 400) return 'Geçerli bir değer girin';
                return null;
              },
              onFieldSubmitted: (_) {
                if (!_saving) _kaydet();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _tarihSec,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text('Tarih: ${uzunTarih(_tarih)}'),
            ),
            if (_hata != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AlertBanner(message: _hata!),
            ],
            const SizedBox(height: AppSpacing.lg),
            LoadingButton(
              label: 'Kaydet',
              icon: Icons.check_rounded,
              loading: _saving,
              onPressed: _kaydet,
            ),
          ],
        ),
      ),
    );
  }
}
