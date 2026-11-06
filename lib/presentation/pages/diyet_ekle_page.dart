import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/diyet_repository.dart';
import '../widgets/app_ui.dart';

/// Diyetisyenin (veya admin'in) yeni diyet programı eklediği form.
/// Başarılı kayıtta `true` ile kapanır.
class DiyetEklePage extends StatefulWidget {
  const DiyetEklePage({super.key, this.diyetisyenAdi});

  /// Formda önceden doldurulacak diyetisyen adı.
  final String? diyetisyenAdi;

  @override
  State<DiyetEklePage> createState() => _DiyetEklePageState();
}

class _DiyetEklePageState extends State<DiyetEklePage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = DiyetRepository();

  final _baslik = TextEditingController();
  late final _diyetisyen = TextEditingController(text: widget.diyetisyenAdi);
  final _aciklama = TextEditingController();
  final _kalori = TextEditingController();
  final _sure = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_baslik, _diyetisyen, _aciklama, _kalori, _sure]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _orNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _repository.addDiyet(
        baslik: _baslik.text.trim(),
        diyetisyen: _diyetisyen.text.trim(),
        aciklama: _orNull(_aciklama),
        kalori: int.tryParse(_kalori.text.trim()),
        sure: _orNull(_sure),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Diyet programı eklendi.')));
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('[DiyetEkle] Hata: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Diyet eklenemedi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Diyet Programı')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            TextFormField(
              controller: _baslik,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Başlık *',
                hintText: 'örn. Akdeniz Diyeti',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Başlık gerekli' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _diyetisyen,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Diyetisyen *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Diyetisyen adı gerekli'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _aciklama,
              minLines: 4,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                hintText: 'Programın içeriği, öğün önerileri...',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _kalori,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kalori (kcal)',
                      prefixIcon: Icon(Icons.local_fire_department),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final n = int.tryParse(v.trim());
                      return (n == null || n <= 0) ? 'Geçerli sayı' : null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _sure,
                    decoration: const InputDecoration(
                      labelText: 'Süre',
                      hintText: 'örn. 4 hafta',
                      prefixIcon: Icon(Icons.schedule),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
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
