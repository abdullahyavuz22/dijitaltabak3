import 'package:flutter/material.dart';

class FavorilerPage extends StatelessWidget {
  final Set<String> favorites;
  final List<Map<String, dynamic>> tarifler;
  final void Function(String isim) onToggleFavorite;

  const FavorilerPage({
    super.key,
    required this.favorites,
    required this.tarifler,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final favTarifler =
        tarifler.where((t) => favorites.contains(t['isim'])).toList();

    return favTarifler.isEmpty
        ? const Center(
            child: Text(
              "Henüz favori yemek eklenmedi.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: favTarifler.length,
              itemBuilder: (context, index) {
                final t = favTarifler[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (t['resim'] != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.asset(
                              t['resim'],
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
                                t['isim'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite,
                                    color: Colors.red),
                                onPressed: () =>
                                    onToggleFavorite(t['isim'] ?? ''),
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
