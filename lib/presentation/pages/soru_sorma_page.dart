import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SoruSormaPage extends StatefulWidget {
  const SoruSormaPage({super.key});

  @override
  State<SoruSormaPage> createState() => _SoruSormaPageState();
}

class _SoruSormaPageState extends State<SoruSormaPage> {
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _konuController = TextEditingController();
  final TextEditingController _soruController = TextEditingController();
  final List<Map<String, String>> sorular = [];

  void soruEkle() {
    if (_mailController.text.isEmpty ||
        _konuController.text.isEmpty ||
        _soruController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tüm alanları doldurun")),
      );
      return;
    }
    setState(() {
      sorular.add({
        "mail": _mailController.text,
        "konu": _konuController.text,
        "soru": _soruController.text,
      });
    });
    _mailController.clear();
    _konuController.clear();
    _soruController.clear();
  }

  Widget _inputBox(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soru Sor",
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _inputBox(_mailController, "Email adresiniz"),
            const SizedBox(height: 12),
            _inputBox(_konuController, "Konu"),
            const SizedBox(height: 12),
            _inputBox(_soruController, "Sorunuz", maxLines: 4),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: soruEkle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: const Text(
                  "Soruyu Gönder",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: sorular.length,
                itemBuilder: (context, index) {
                  final soru = sorular[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(soru["konu"] ?? ""),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Gönderen: ${soru["mail"]}"),
                          const SizedBox(height: 5),
                          Text(soru["soru"] ?? ""),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
