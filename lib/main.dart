import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/config/supabase_config.dart';
import 'data/models/recipe_model.dart';
import 'domain/entities/recipe.dart';
import 'presentation/pages/anasayfa_page.dart';
import 'presentation/pages/favoriler_page.dart';
import 'presentation/pages/profil_page.dart';
import 'presentation/pages/soru_sorma_page.dart';
import 'presentation/pages/tarifler_page.dart';
import 'presentation/pages/videolu_tarifler_page.dart';
import 'presentation/pages/diyetler_page.dart';
import 'presentation/pages/vki_hesaplama_page.dart';
import 'presentation/pages/giris_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    if (url.isNotEmpty && key.isNotEmpty) {
      await Supabase.initialize(url: url, anonKey: key);
    }
  } catch (_) {}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loggedIn = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    bool supabaseReady;
    try {
      Supabase.instance.client;
      supabaseReady = true;
    } catch (_) {
      supabaseReady = false;
    }

    if (!supabaseReady) {
      setState(() {
        _loggedIn = true; // Supabase yoksa direkt uygulama açılsın
        _ready = true;
      });
      return;
    }

    final currentSession = SupabaseConfig.client.auth.currentSession;
    setState(() {
      _loggedIn = currentSession != null;
      _ready = true;
    });

    SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      setState(() => _loggedIn = data.session != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _loggedIn ? const MainPage() : const GirisPage();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  List<Recipe> _recipes = [];
  final Set<String> _favorites = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _loadFavorites();
  }

  Future<void> _loadRecipes() async {
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
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final response = await SupabaseConfig.client
          .from('favoriler')
          .select('recipe_id');
      final ids = (response as List)
          .where((e) => e['recipe_id'] != null)
          .map((e) => e['recipe_id'] as String)
          .toSet();
      if (mounted) setState(() => _favorites.addAll(ids));
    } catch (_) {}
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    final isFavorite = _favorites.contains(recipe.id);

    setState(() {
      if (isFavorite) {
        _favorites.remove(recipe.id);
      } else {
        _favorites.add(recipe.id);
      }
    });

    try {
      if (isFavorite) {
        await SupabaseConfig.client
            .from('favoriler')
            .delete()
            .eq('recipe_id', recipe.id);
      } else {
        await SupabaseConfig.client
            .from('favoriler')
            .insert({'recipe_id': recipe.id});
      }
    } catch (e) {
      debugPrint('[Favori] DB HATASI: $e');
      if (mounted) {
        setState(() {
          if (isFavorite) {
            _favorites.add(recipe.id);
          } else {
            _favorites.remove(recipe.id);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dijital Tabağım',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Text(
                'Menü',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              title: const Text('Diyetisyen Önerileri'),
              leading: const Icon(Icons.medical_services,
                  color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Beslenme Takvimi'),
              leading: const Icon(Icons.calendar_month,
                  color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Videolu Tarifler'),
              leading: const Icon(Icons.play_circle_fill,
                  color: AppColors.primary),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const VideoluTariflerPage()));
              },
            ),
            ListTile(
              title: const Text('VKI Hesaplama'),
              leading: const Icon(Icons.monitor_weight,
                  color: AppColors.primary),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const VkiHesaplamaPage()));
              },
            ),
            ListTile(
              title: const Text('Tarifler'),
              leading: const Icon(Icons.restaurant_menu,
                  color: AppColors.primary),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const TariflerPage()));
              },
            ),
            ListTile(
              title: const Text('Diyetler'),
              leading: const Icon(Icons.local_fire_department,
                  color: AppColors.primary),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const DiyetlerPage()));
              },
            ),
            ListTile(
              title: const Text('Blog'),
              leading: const Icon(Icons.article, color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Soru Sor'),
              leading: const Icon(Icons.help_outline,
                  color: AppColors.primary),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const SoruSormaPage()));
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Çıkış Yap',
                  style: TextStyle(color: Colors.red)),
              leading: const Icon(Icons.logout, color: Colors.red),
              onTap: () async {
                Navigator.pop(context);
                await SupabaseConfig.client.auth.signOut();
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: [
                AnasayfaPage(
                  recipes: _recipes,
                  favorites: _favorites,
                  onToggleFavorite: _toggleFavorite,
                ),
                const Center(child: Text('Arama')),
                FavorilerPage(
                  recipes: _recipes,
                  favorites: _favorites,
                  onToggleFavorite: _toggleFavorite,
                ),
                const ProfilPage(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Anasayfa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Arama'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favoriler'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
