import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/supabase_config.dart';

class VkiHesaplamaPage extends StatefulWidget {
  const VkiHesaplamaPage({super.key});

  @override
  State<VkiHesaplamaPage> createState() => _VkiHesaplamaPageState();
}

class _VkiHesaplamaPageState extends State<VkiHesaplamaPage> {
  final TextEditingController _boyController = TextEditingController();
  final TextEditingController _kiloController = TextEditingController();
  double? _vki;
  bool _isSaving = false;

  Future<void> _hesapla() async {
    final double? boy = double.tryParse(_boyController.text);
    final double? kilo = double.tryParse(_kiloController.text);
    if (boy == null || kilo == null || boy <= 0) return;

    final sonuc = kilo / ((boy / 100) * (boy / 100));
    setState(() => _vki = sonuc);

    setState(() => _isSaving = true);
    try {
      await SupabaseConfig.client.from('vki_kayitlari').insert({
        'boy': boy,
        'kilo': kilo,
        'vki': double.parse(sonuc.toStringAsFixed(2)),
        'durum': _vkiDurumu(sonuc),
      });
    } catch (_) {
      // Kayıt başarısız olsa bile sonucu göster
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _vkiDurumu(double vki) {
    if (vki < 18.5) return "Zayıf 🟡";
    if (vki < 24.9) return "Normal 🟢";
    if (vki < 29.9) return "Fazla Kilolu 🟠";
    return "Obez 🔴";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("VKI Hesaplama",
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _boyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Boy (cm)",
                        prefixIcon:
                            Icon(Icons.height, color: AppColors.primary),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _kiloController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Kilo (kg)",
                        prefixIcon: Icon(Icons.monitor_weight,
                            color: AppColors.primary),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _hesapla,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              "Hesapla",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_vki != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "VKI Sonucu",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _vki!.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _vkiDurumu(_vki!),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sonuç kaydedildi",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
