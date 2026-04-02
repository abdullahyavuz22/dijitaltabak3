import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/recipe.dart';
import 'recipe_detay_page.dart';

class AnasayfaPage extends StatefulWidget {
  final List<Recipe> recipes;
  final Set<String> favorites;
  final void Function(Recipe recipe) onToggleFavorite;

  const AnasayfaPage({
    super.key,
    required this.recipes,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  State<AnasayfaPage> createState() => _AnasayfaPageState();
}

class _AnasayfaPageState extends State<AnasayfaPage> {
  String selectedCategory = 'Hepsi';

  final List<String> imgList = [
    'assets/images/resim-1.jpeg',
    'assets/images/resim-2.jpg',
    'assets/images/resim-3.jpg',
    'assets/images/resim-4.jpg',
    'assets/images/resim-5.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == 'Hepsi'
        ? widget.recipes
        : widget.recipes
            .where((r) => r.category == selectedCategory)
            .toList();

    final categories = [
      'Hepsi',
      ...{
        for (final r in widget.recipes)
          if (r.category != null && r.category!.isNotEmpty) r.category!,
      },
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // Carousel
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
            ),
            items: imgList
                .map((item) => ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        item,
                        fit: BoxFit.cover,
                        width: 1000,
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Hoş Geldiniz!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          // Kategori filtreleri
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kategoriler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = cat == selectedCategory;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => selectedCategory = cat),
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      backgroundColor:
                          isSelected ? AppColors.primary : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      elevation: isSelected ? 3 : 0,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tarif kartları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: filtered.map((recipe) {
                final isFavorite = widget.favorites.contains(recipe.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetayPage(recipe: recipe),
                      ),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (recipe.imageUrl != null)
                            Image.network(
                              recipe.imageUrl!,
                              height: 160,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                height: 160,
                                color: Colors.grey[200],
                                child: const Icon(Icons.restaurant,
                                    size: 48, color: Colors.grey),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipe.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (recipe.duration != null ||
                                          recipe.rating != null)
                                        const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (recipe.duration != null) ...[
                                            const Icon(Icons.timer_outlined,
                                                size: 13,
                                                color: AppColors.primary),
                                            const SizedBox(width: 3),
                                            Text(
                                              recipe.duration!,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.primary),
                                            ),
                                            const SizedBox(width: 10),
                                          ],
                                          if (recipe.rating != null) ...[
                                            const Icon(Icons.star_rounded,
                                                size: 13,
                                                color: Colors.amber),
                                            const SizedBox(width: 3),
                                            Text(
                                              recipe.rating!
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: () =>
                                      widget.onToggleFavorite(recipe),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
