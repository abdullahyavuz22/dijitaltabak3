import 'package:flutter/material.dart';
import '../../core/config/supabase_config.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/recipe_model.dart';
import '../../domain/entities/recipe.dart';
import '../widgets/app_ui.dart';
import '../widgets/recipe_card.dart';

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
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hata = null;
      });
    }
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
      appBar: AppBar(title: const Text('Tarifler')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hata != null
          ? ErrorState(
              message: 'Tarifler yüklenemedi.\n$_hata',
              onRetry: _loadRecipes,
            )
          : _recipes.isEmpty
          ? const EmptyState(
              icon: Icons.restaurant_menu_rounded,
              title: 'Henüz tarif eklenmemiş',
              message: 'Yeni tarifler eklendiğinde burada görünecek.',
            )
          : RefreshIndicator(
              onRefresh: _loadRecipes,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                itemCount: _recipes.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    RecipeCard(recipe: _recipes[index]),
              ),
            ),
    );
  }
}
