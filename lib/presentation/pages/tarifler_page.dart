import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/supabase_config.dart';
import '../../data/models/recipe_model.dart';
import '../../domain/entities/recipe.dart';
import 'recipe_detay_page.dart';

class TariflerPage extends StatefulWidget {
  const TariflerPage({super.key});

  @override
  State<TariflerPage> createState() => _TariflerPageState();
}

class _TariflerPageState extends State<TariflerPage> {
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    if (mounted) setState(() { _isLoading = true; _hata = null; });
    try {
      final response = await SupabaseConfig.client
          .from('recipes')
          .select()
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _recipes = (response as List)
              .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hata = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarifler', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hata != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          'Tarifler yüklenemedi:\n$_hata',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRecipes,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : _recipes.isEmpty
                  ? const Center(
                      child: Text(
                        'Henüz tarif eklenmemiş.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRecipes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          return _RecipeKart(recipe: _recipes[index]);
                        },
                      ),
                    ),
    );
  }
}

class _RecipeKart extends StatelessWidget {
  final Recipe recipe;

  const _RecipeKart({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetayPage(recipe: recipe),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görsel
            SizedBox(
              height: 180,
              width: double.infinity,
              child: recipe.imageUrl != null
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık + kategori
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (recipe.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            recipe.category!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Süre ve yıldız
                  Row(
                    children: [
                      if (recipe.duration != null) ...[
                        const Icon(Icons.timer_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          recipe.duration!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (recipe.rating != null) ...[
                        const Icon(Icons.star_rounded,
                            size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          recipe.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.restaurant, size: 48, color: Colors.grey),
        ),
      );
}
