import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../data/tarifler_data.dart';

class AnasayfaPage extends StatefulWidget {
  final Set<String> favorites;
  final void Function(String isim) onToggleFavorite;

  const AnasayfaPage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  State<AnasayfaPage> createState() => _AnasayfaPageState();
}

class _AnasayfaPageState extends State<AnasayfaPage> {
  String selectedCategory = "Hepsi";
  String? selectedTag;

  final List<String> imgList = [
    "assets/images/resim-1.jpeg",
    "assets/images/resim-2.jpg",
    "assets/images/resim-3.jpg",
    "assets/images/resim-4.jpg",
    "assets/images/resim-5.jpg",
  ];

  @override
  Widget build(BuildContext context) {

    final filteredTarifler =
        (selectedTag != null && selectedTag!.isNotEmpty)
            ? tarifler.where((t) {
                final tags = List.from(t['etiketler'] ?? []);
                return tags.contains(selectedTag);
              }).toList()
            : (selectedCategory == 'Hepsi'
                ? tarifler
                : tarifler
                    .where((t) => t['kategori'] == selectedCategory)
                    .toList());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 10),

          /// CAROUSEL
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// CATEGORIES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Builder(builder: (context) {

                  final Set<String> catSet = {};

                  for (final t in tarifler) {
                    final k = t['kategori'];
                    if (k != null && k.isNotEmpty) {
                      catSet.add(k);
                    }
                  }

                  final List<String> categoryList =
                      ['Hepsi', ...catSet];

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categoryList.map((category) {

                      final bool isSelected =
                          category == selectedCategory;

                      return ChoiceChip(
                        label: Text(category),

                        selected: isSelected,

                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = category;
                            selectedTag = null;
                          });
                        },

                        showCheckmark: false,

                        selectedColor: Color(0xFF68BE6D),

                        backgroundColor: isSelected
                            ? Color(0xFF68BE6D)
                            : Colors.grey.shade200,

                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),

                        elevation: isSelected ? 3 : 0,
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// TAGS
          Builder(builder: (context) {

            final Set<String> tagSet = {};

            for (final t in tarifler) {
              final tags = List.from(t['etiketler'] ?? []);
              for (final tag in tags) {
                tagSet.add(tag.toString());
              }
            }

            final List<String> allTags = tagSet.toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: allTags.map((tag) {

                    final bool isSelectedTag =
                        selectedTag == tag ||
                        (tag == 'Hepsi' &&
                            selectedTag == null &&
                            selectedCategory == 'Hepsi');

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),

                      child: GestureDetector(
                        onTap: () {
                          setState(() {

                            if (tag == 'Hepsi') {
                              selectedTag = null;
                              selectedCategory = 'Hepsi';
                            } else {
                              selectedTag = tag;
                              selectedCategory = 'Hepsi';
                            }

                          });
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),

                          decoration: BoxDecoration(
                            color: isSelectedTag
                                ? Color(0xFF68BE6D)
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
            );
          }),

          const SizedBox(height: 20),

          /// TARİF LİSTESİ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: filteredTarifler.map((t) {

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
                            borderRadius:
                                const BorderRadius.vertical(
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
                                icon: Icon(
                                  widget.favorites.contains(t['isim'])
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: widget.favorites.contains(t['isim'])
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () =>
                                    widget.onToggleFavorite(t['isim'] ?? ''),
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