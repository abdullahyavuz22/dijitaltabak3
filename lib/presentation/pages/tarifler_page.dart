import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/tarif.dart';

class TariflerPage extends StatelessWidget {
  final List<Tarif> tarifler;

  const TariflerPage({super.key, required this.tarifler});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tarifler",
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: tarifler.length,
        itemBuilder: (context, index) {
          final tarif = tarifler[index];
          return Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                if (tarif.resim != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15)),
                    child: Image.asset(
                      tarif.resim!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ListTile(
                  title: Text(
                    tarif.isim,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: tarif.kategori != null
                      ? Text(tarif.kategori!)
                      : null,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${tarif.isim} seçildi")),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
