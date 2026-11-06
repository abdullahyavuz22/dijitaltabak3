import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/diyet_repository.dart';
import '../../domain/entities/diyet.dart';
import '../viewmodels/favori_store.dart';
import '../widgets/app_ui.dart';
import 'diyet_detay_page.dart';
import 'diyet_ekle_page.dart';

class DiyetlerPage extends StatefulWidget {
  const DiyetlerPage({super.key});

  @override
  State<DiyetlerPage> createState() => _DiyetlerPageState();
}

class _DiyetlerPageState extends State<DiyetlerPage> {
  List<Diyet> _diyetler = [];
  bool _isLoading = true;
  String? _hata;

  final _diyetRepository = DiyetRepository();
  final _favoriler = FavoriStore.instance;
  final _authRepository = AuthRepository();

  /// Diyetisyen veya admin ise "Diyet Ekle" butonu gösterilir.
  bool _canAdd = false;

  @override
  void initState() {
    super.initState();
    _loadDiyetler();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final canAdd = await _authRepository.canManageDiets();
      if (mounted) setState(() => _canAdd = canAdd);
    } catch (_) {}
  }

  Future<void> _openEkle() async {
    String? ad;
    try {
      ad = await _authRepository.currentUserFullName();
    } catch (_) {}
    if (!mounted) return;
    final eklendi = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DiyetEklePage(diyetisyenAdi: ad)),
    );
    if (eklendi == true) _loadDiyetler();
  }

  Future<void> _loadDiyetler() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hata = null;
      });
    }
    try {
      final diyetler = await _diyetRepository.fetchDiyetler();
      if (mounted) {
        setState(() {
          _diyetler = diyetler;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Diyetler] Hata: $e');
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
      appBar: AppBar(title: const Text('Diyet Programları')),
      floatingActionButton: _canAdd
          ? FloatingActionButton.extended(
              onPressed: _openEkle,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Diyet Ekle'),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hata != null
          ? ErrorState(
              message: 'Diyetler yüklenemedi.\n$_hata',
              onRetry: _loadDiyetler,
            )
          : _diyetler.isEmpty
          ? EmptyState(
              icon: Icons.local_fire_department_outlined,
              title: 'Henüz diyet programı yok',
              message: _canAdd
                  ? 'İlk programı eklemek için aşağıdaki butonu kullanın.'
                  : 'Diyetisyenler program paylaştığında burada görünecek.',
            )
          : RefreshIndicator(
              onRefresh: _loadDiyetler,
              child: ListenableBuilder(
                listenable: _favoriler,
                builder: (context, _) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    96,
                  ),
                  itemCount: _diyetler.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final diyet = _diyetler[index];
                    return DiyetKarti(
                      diyet: diyet,
                      isFavorite: _favoriler.isDiyetFavorite(diyet),
                      onToggleFavorite: diyet.id == null
                          ? null
                          : () => runFavoriteToggle(
                              context,
                              () => _favoriler.toggleDiyet(diyet),
                              wasFavorite: _favoriler.isDiyetFavorite(diyet),
                            ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

/// Diyet programı kartı (Diyetler + Favoriler).
class DiyetKarti extends StatelessWidget {
  final Diyet diyet;
  final bool isFavorite;

  /// Null ise favori butonu gösterilmez.
  final VoidCallback? onToggleFavorite;

  const DiyetKarti({
    super.key,
    required this.diyet,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DiyetDetayPage(diyet: diyet)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const IconBadge(
                    icon: Icons.restaurant_menu_rounded,
                    size: 48,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diyet.baslik,
                          style: text.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 14,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                diyet.diyetisyen,
                                style: text.labelMedium?.copyWith(
                                  color: scheme.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onToggleFavorite != null)
                    FavoriteIconButton(
                      isFavorite: isFavorite,
                      onPressed: onToggleFavorite,
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                ],
              ),
              if (diyet.aciklama != null && diyet.aciklama!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  diyet.aciklama!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (diyet.kalori != null || diyet.sure != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (diyet.kalori != null)
                      InfoPill(
                        icon: Icons.local_fire_department_rounded,
                        label: '${diyet.kalori} kcal',
                        color: const Color(0xFFC46A00),
                      ),
                    if (diyet.sure != null)
                      InfoPill(
                        icon: Icons.schedule_rounded,
                        label: diyet.sure!,
                        color: AppColors.info,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
