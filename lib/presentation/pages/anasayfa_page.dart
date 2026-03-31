import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/tarif.dart';

class AnasayfaPage extends StatefulWidget {
  final List<Tarif> tarifler;
  final Set<String> favorites;
  final void Function(String isim) onToggleFavorite;

  const AnasayfaPage({
    super.key,
    required this.tarifler,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  State<AnasayfaPage> createState() => _AnasayfaPageState();
}

class _AnasayfaPageState extends State<AnasayfaPage> {
  String selectedCategory = "Hepsi";
  final List<String> imgList = [
    "assets/images/resim-1.jpeg",
    "assets/images/resim-2.jpg",
    "assets/images/resim-3.jpg",
    "assets/images/resim-4.jpg",
    "assets/images/resim-5.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTarifler = (selectedTag != null && selectedTag!.isNotEmpty)
        ? widget.tarifler
            .where((t) => t.etiketler.contains(selectedTag))
            .toList()
        : (selectedCategory == 'Hepsi'
            ? widget.tarifler
            : widget.tarifler
                .where((t) => t.kategori == selectedCategory)
                .toList());

    final Set<String> catSet = {};
    for (final t in widget.tarifler) {
      if (t.kategori != null && t.kategori!.isNotEmpty) {
        catSet.add(t.kategori!);
      }
    }
    final categoryList = ['Hepsi', ...catSet];

    final Set<String> tagSet = {};
    for (final t in widget.tarifler) {
      for (final tag in t.etiketler) {
        tagSet.add(tag);
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // CAROUSEL
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
            ),
            items: imgList
                .map(
                  (item) => ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      item,
                      fit: BoxFit.cover,
                      width: 1000,
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              "Hoş Geldiniz!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          // KATEGORILER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kategoriler",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categoryList.map((category) {
                    final isSelected = category == selectedCategory;
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                          selectedTag = null;
                        });
                      },
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

          const SizedBox(height: 16),

          // ETİKETLER
          if (tagSet.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tagSet.map((tag) {
                    final isSelectedTag = selectedTag == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTag = isSelectedTag ? null : tag;
                            selectedCategory = 'Hepsi';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelectedTag
                                ? AppColors.primary
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isSelectedTag
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: isSelectedTag
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // TARİF LİSTESİ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: filteredTarifler.map((tarif) {
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  widget.favorites.contains(tarif.isim)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: widget.favorites.contains(tarif.isim)
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () =>
                                    widget.onToggleFavorite(tarif.isim),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
