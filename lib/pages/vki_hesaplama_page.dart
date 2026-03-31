import 'package:flutter/material.dart';

class VkiHesaplamaPage extends StatefulWidget {
  const VkiHesaplamaPage({super.key});

  @override
  State<VkiHesaplamaPage> createState() => _VkiHesaplamaPageState();
}

class _VkiHesaplamaPageState extends State<VkiHesaplamaPage> {
  final TextEditingController _boyController = TextEditingController();
  final TextEditingController _kiloController = TextEditingController();
  double? _vki;

  void _hesapla() {
    final double? boy = double.tryParse(_boyController.text);
    final double? kilo = double.tryParse(_kiloController.text);

    if (boy != null && kilo != null && boy > 0) {
      setState(() {
        _vki = kilo / ((boy / 100) * (boy / 100));
      });
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
        title: const Text("VKI Hesaplama"),
        backgroundColor: const Color(0xFF68BE6D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                        prefixIcon: Icon(
                          Icons.height,
                          color: Color(0xFF68BE6D),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _kiloController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Kilo (kg)",
                        prefixIcon: Icon(
                          Icons.monitor_weight,
                          color: Color(0xFF68BE6D),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _hesapla,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Hesapla",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                      color: Colors.black.withOpacity(0.1),
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
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _vki!.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF68BE6D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _vkiDurumu(_vki!),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
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
