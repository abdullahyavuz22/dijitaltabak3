import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'data/repositories/tarif_repository_impl.dart';
import 'domain/entities/tarif.dart';
import 'domain/usecases/get_tarifler.dart';
import 'presentation/pages/anasayfa_page.dart';
import 'presentation/pages/favoriler_page.dart';
import 'presentation/pages/profil_page.dart';
import 'presentation/pages/soru_sorma_page.dart';
import 'presentation/pages/tarifler_page.dart';
import 'presentation/pages/videolu_tarifler_page.dart';
import 'presentation/pages/vki_hesaplama_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final Set<String> _favorites = {};
  late final List<Tarif> _tarifler;

  @override
  void initState() {
    super.initState();
    _tarifler = GetTarifler(TarifRepositoryImpl()).call();
  }

  void _toggleFavorite(String isim) {
    setState(() {
      if (_favorites.contains(isim)) {
        _favorites.remove(isim);
      } else {
        _favorites.add(isim);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dijital Tabağım",
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
                "Menü",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              title: const Text("Diyetisyen Önerileri"),
              leading: const Icon(Icons.medical_services,
                  color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text("Beslenme Takvimi"),
              leading:
                  const Icon(Icons.calendar_month, color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text("Videolu Tarifler"),
              leading: const Icon(Icons.play_circle_fill,
                  color: AppColors.primary),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const VideoluTariflerPage()),
                );
              },
            ),
            ListTile(
              title: const Text("VKI Hesaplama"),
              leading:
                  const Icon(Icons.monitor_weight, color: AppColors.primary),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const VkiHesaplamaPage()),
                );
              },
            ),
            ListTile(
              title: const Text("Tarifler"),
              leading: const Icon(Icons.restaurant_menu,
                  color: AppColors.primary),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TariflerPage(tarifler: _tarifler)),
                );
              },
            ),
            ListTile(
              title: const Text("Diyetler"),
              leading: const Icon(Icons.local_fire_department,
                  color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text("Blog"),
              leading: const Icon(Icons.article, color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text("Soru Sor"),
              leading:
                  const Icon(Icons.help_outline, color: AppColors.primary),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SoruSormaPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          AnasayfaPage(
            tarifler: _tarifler,
            favorites: _favorites,
            onToggleFavorite: _toggleFavorite,
          ),
          const Center(child: Text("Arama")),
          FavorilerPage(
            tarifler: _tarifler,
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
              icon: Icon(Icons.home), label: "Anasayfa"),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: "Arama"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favoriler"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
