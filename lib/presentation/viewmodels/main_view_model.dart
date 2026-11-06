import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../domain/entities/recipe.dart';

/// `MainPage` görünümünün view model'i: sekme, tarifler ve favoriler.
class MainViewModel extends ChangeNotifier {
  MainViewModel({
    RecipeRepository? recipeRepository,
    AuthRepository? authRepository,
  }) : _recipeRepository = recipeRepository ?? RecipeRepository(),
       _authRepository = authRepository ?? AuthRepository();

  final RecipeRepository _recipeRepository;
  final AuthRepository _authRepository;

  int _tabIndex = 0;
  List<Recipe> _recipes = [];
  final Set<String> _favorites = {};
  bool _isLoading = true;
  bool _isAdmin = false;

  int get tabIndex => _tabIndex;
  List<Recipe> get recipes => _recipes;
  Set<String> get favorites => _favorites;
  bool get isLoading => _isLoading;

  /// Sadece admin rolündeki kullanıcılar tarif/içerik ekleyebilir.
  bool get isAdmin => _isAdmin;

  set tabIndex(int value) {
    if (_tabIndex == value) return;
    _tabIndex = value;
    notifyListeners();
  }

  Future<void> load() =>
      Future.wait([_loadRecipes(), _loadFavorites(), _loadRole()]);

  Future<void> _loadRole() async {
    try {
      _isAdmin = await _authRepository.isCurrentUserAdmin();
      notifyListeners();
    } catch (_) {}
  }

  /// Admin olmayan bir kullanıcı çağırırsa Supabase RLS ekleme isteğini
  /// reddeder; hata çağırana (UI) yansıtılır.
  Future<void> addRecipe({
    required String name,
    String? imageUrl,
    String? category,
    String? duration,
    double? rating,
  }) async {
    await _recipeRepository.addRecipe(
      name: name,
      imageUrl: imageUrl,
      category: category,
      duration: duration,
      rating: rating,
    );
    await _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      _recipes = await _recipeRepository.fetchRecipes();
    } catch (_) {
      // Sessizce yut — liste boş kalır.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFavorites() async {
    try {
      _favorites
        ..clear()
        ..addAll(await _recipeRepository.fetchFavoriteIds());
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final wasFavorite = _favorites.contains(recipe.id);

    // Optimistik güncelleme
    _setFavorite(recipe.id, !wasFavorite);

    try {
      wasFavorite
          ? await _recipeRepository.removeFavorite(recipe.id)
          : await _recipeRepository.addFavorite(recipe.id);
    } catch (e) {
      debugPrint('[Favori] DB HATASI: $e');
      _setFavorite(recipe.id, wasFavorite); // geri al
    }
  }

  void _setFavorite(String recipeId, bool value) {
    value ? _favorites.add(recipeId) : _favorites.remove(recipeId);
    notifyListeners();
  }

  Future<void> signOut() => _authRepository.signOut();
}
