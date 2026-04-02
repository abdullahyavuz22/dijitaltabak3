import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/recipe.dart';

class RecipeDetayPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetayPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              background: recipe.imageUrl != null
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Özet bilgiler
                  Row(
                    children: [
                      if (recipe.rating != null)
                        Expanded(
                          child: _InfoKutu(
                            icon: Icons.star_rounded,
                            iconColor: Colors.amber,
                            baslik: 'Puan',
                            deger: recipe.rating!.toStringAsFixed(1),
                          ),
                        ),
                      if (recipe.rating != null && recipe.duration != null)
                        const SizedBox(width: 12),
                      if (recipe.duration != null)
                        Expanded(
                          child: _InfoKutu(
                            icon: Icons.timer_outlined,
                            iconColor: AppColors.primary,
                            baslik: 'Süre',
                            deger: recipe.duration!,
                          ),
                        ),
                      if (recipe.category != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoKutu(
                            icon: Icons.category_outlined,
                            iconColor: AppColors.primary,
                            baslik: 'Kategori',
                            deger: recipe.category!,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Malzemeler
                  if (recipe.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _SectionBaslik(
                        title: 'Malzemeler',
                        icon: Icons.list_alt_outlined),
                    const SizedBox(height: 10),
                    _ListeKutu(
                      items: recipe.ingredients,
                      bullet: '•',
                    ),
                  ],

                  // Yapılış
                  if (recipe.instructions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _SectionBaslik(
                        title: 'Yapılış',
                        icon: Icons.menu_book_outlined),
                    const SizedBox(height: 10),
                    _ListeKutu(
                      items: recipe.instructions,
                      numbered: true,
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.restaurant, size: 60, color: Colors.white54),
        ),
      );
}

class _InfoKutu extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String baslik;
  final String deger;

  const _InfoKutu({
    required this.icon,
    required this.iconColor,
    required this.baslik,
    required this.deger,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 6),
          Text(
            deger,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            baslik,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _SectionBaslik extends StatelessWidget {
  final String title;
  final IconData icon;

  // ignore: unused_element
  const _SectionBaslik({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ListeKutu extends StatelessWidget {
  final List<String> items;
  final bool numbered;
  final String bullet;

  const _ListeKutu({
    required this.items,
    this.numbered = false,
    this.bullet = '•',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (i) {
          final prefix = numbered ? '${i + 1}.' : bullet;
          return Padding(
            padding: EdgeInsets.only(bottom: i < items.length - 1 ? 10 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    prefix,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    items[i],
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
