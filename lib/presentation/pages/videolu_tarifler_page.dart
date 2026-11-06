import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/supabase_config.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/entities/video.dart';
import '../viewmodels/favori_store.dart';
import '../widgets/app_ui.dart';

class VideoluTariflerPage extends StatefulWidget {
  const VideoluTariflerPage({super.key, this.initialVideoId});

  /// Açılışta seçili olacak YouTube video id'si (örn. Favoriler'den gelince).
  final String? initialVideoId;

  @override
  State<VideoluTariflerPage> createState() => _VideoluTariflerPageState();
}

class _VideoluTariflerPageState extends State<VideoluTariflerPage> {
  final _favoriler = FavoriStore.instance;
  List<Video> _videolar = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _loadVideolar();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadVideolar() async {
    List<Video> list;
    try {
      final response = await SupabaseConfig.client
          .from('videolu_tarifler')
          .select()
          .order('created_at');
      list = (response as List)
          .map((e) => Video.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Çevrimdışı yedek (id yok → favorilenemez)
      list = const [
        Video(baslik: 'Menemen Tarifi', videoId: 'ajdSDri1c-U'),
        Video(baslik: 'Kuru Fasulye Tarifi', videoId: '7rORG0W31aE'),
      ];
    }
    if (!mounted) return;

    final initial = list.indexWhere((v) => v.videoId == widget.initialVideoId);
    setState(() {
      _videolar = list;
      _selectedIndex = initial < 0 ? 0 : initial;
      _isLoading = false;
    });
    if (list.isNotEmpty) _initPlayer(list[_selectedIndex].videoId);
  }

  void _initPlayer(String videoId) {
    _controller?.dispose();
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.initialVideoId != null,
        mute: false,
        enableCaption: false,
        forceHD: false,
        useHybridComposition: true,
      ),
    );
    if (mounted) setState(() {});
  }

  void _selectVideo(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _controller?.load(_videolar[index].videoId);
  }

  void _toggleFavori(Video v) => runFavoriteToggle(
    context,
    () => _favoriler.toggleVideo(v),
    wasFavorite: _favoriler.isVideoFavorite(v),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller ?? YoutubePlayerController(initialVideoId: ''),
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primaryLight,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.primaryLight,
          handleColor: AppColors.primaryLight,
        ),
      ),
      builder: (context, player) {
        final selected = _videolar.isEmpty ? null : _videolar[_selectedIndex];
        return Scaffold(
          appBar: AppBar(title: const Text('Videolu Tarifler')),
          body: ListenableBuilder(
            listenable: _favoriler,
            builder: (context, _) => Column(
              children: [
                // ── Video oynatıcı ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: ClipRRect(
                    borderRadius: AppRadius.lgAll,
                    child: _controller != null
                        ? player
                        : const AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ColoredBox(
                              color: Colors.black,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                if (selected != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.xs,
                      0,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.graphic_eq_rounded,
                          color: scheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            selected.baslik,
                            style: text.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (selected.id != null)
                          FavoriteIconButton(
                            isFavorite: _favoriler.isVideoFavorite(selected),
                            onPressed: () => _toggleFavori(selected),
                          ),
                      ],
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: SectionTitle(
                    title: 'Tüm Videolar',
                    trailing: _isLoading
                        ? null
                        : Text(
                            '${_videolar.length} video',
                            style: text.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),

                // ── Liste ────────────────────────────────────────────
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _videolar.isEmpty
                      ? const EmptyState(
                          icon: Icons.video_library_outlined,
                          title: 'Henüz video yok',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.xs,
                            AppSpacing.md,
                            AppSpacing.xl,
                          ),
                          itemCount: _videolar.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final video = _videolar[index];
                            return VideoKart(
                              video: video,
                              isSelected: _selectedIndex == index,
                              isFavorite: _favoriler.isVideoFavorite(video),
                              onTap: () => _selectVideo(index),
                              onToggleFavorite: video.id == null
                                  ? null
                                  : () => _toggleFavori(video),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Küçük görselli video satırı (Videolu Tarifler + Favoriler).
class VideoKart extends StatelessWidget {
  const VideoKart({
    super.key,
    required this.video,
    required this.onTap,
    this.isSelected = false,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final Video video;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onTap;

  /// Null ise favori butonu gösterilmez.
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(
          color: isSelected ? scheme.primary : scheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? scheme.primary.withValues(alpha: 0.06)
          : scheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.mdAll,
                child: SizedBox(
                  width: 128,
                  height: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetworkThumb(
                        url: video.thumbnailUrl,
                        icon: Icons.video_library_outlined,
                      ),
                      Container(color: Colors.black26),
                      Center(
                        child: Icon(
                          isSelected
                              ? Icons.equalizer_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.baslik,
                      style: text.titleSmall?.copyWith(
                        color: isSelected ? scheme.primary : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSelected ? 'Şimdi oynatılıyor' : 'İzlemek için dokun',
                      style: text.labelSmall?.copyWith(
                        color: isSelected
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onToggleFavorite != null)
                FavoriteIconButton(
                  isFavorite: isFavorite,
                  onPressed: onToggleFavorite,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
