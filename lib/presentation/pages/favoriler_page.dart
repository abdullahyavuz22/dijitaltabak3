import 'package:flutter/material.dart';
import '../../domain/entities/tarif.dart';

class FavorilerPage extends StatelessWidget {
  final List<Tarif> tarifler;
  final Set<String> favorites;
  final void Function(String isim) onToggleFavorite;

  const FavorilerPage({
    super.key,
    required this.tarifler,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final favTarifler =
        tarifler.where((t) => favorites.contains(t.isim)).toList();

    if (favTarifler.isEmpty) {
      return const Center(
        child: Text(
          "Henüz favori yemek eklenmedi.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: favTarifler.length,
        itemBuilder: (context, index) {
          final tarif = favTarifler[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (tarif.resim != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: Image.asset(
                        tarif.resim!,
                        height: 160,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tarif.isim,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () => onToggleFavorite(tarif.isim),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
