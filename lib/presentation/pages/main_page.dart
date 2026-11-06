import 'package:flutter/material.dart';
import '../viewmodels/favori_store.dart';
import '../viewmodels/main_view_model.dart';
import '../widgets/main_drawer.dart';
import 'anasayfa_page.dart';
import 'arama_page.dart';
import 'favoriler_page.dart';
import 'profil_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainViewModel _viewModel = MainViewModel();

  static const _titles = ['Dijital Tabağım', 'Ara', 'Favorilerim', 'Profilim'];

  @override
  void initState() {
    super.initState();
    _viewModel.load();
    FavoriStore.instance.load();
  }

  Future<void> _signOut() async {
    FavoriStore.instance.clear();
    await _viewModel.signOut();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final tab = _viewModel.tabIndex;
        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[tab]),
            actions: [
              if (tab == 0)
                IconButton(
                  tooltip: 'Ara',
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => _viewModel.tabIndex = 1,
                ),
            ],
          ),
          drawer: MainDrawer(onSignOut: _signOut),
          body: _viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: tab,
                  children: [
                    AnasayfaPage(
                      recipes: _viewModel.recipes,
                      favorites: _viewModel.favorites,
                      onToggleFavorite: _viewModel.toggleFavorite,
                      isAdmin: _viewModel.isAdmin,
                      onAddRecipe: _viewModel.addRecipe,
                    ),
                    AramaPage(
                      recipes: _viewModel.recipes,
                      favorites: _viewModel.favorites,
                      onToggleFavorite: _viewModel.toggleFavorite,
                    ),
                    FavorilerPage(
                      recipes: _viewModel.recipes,
                      favorites: _viewModel.favorites,
                      onToggleFavorite: _viewModel.toggleFavorite,
                      onExplore: () => _viewModel.tabIndex = 0,
                    ),
                    const ProfilPage(),
                  ],
                ),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (i) => _viewModel.tabIndex = i,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Anasayfa',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  label: 'Ara',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: 'Favoriler',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
