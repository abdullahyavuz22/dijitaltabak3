import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/supabase_config.dart';

class VideoluTariflerPage extends StatefulWidget {
  const VideoluTariflerPage({super.key});

  @override
  State<VideoluTariflerPage> createState() => _VideoluTariflerPageState();
}

class _VideoluTariflerPageState extends State<VideoluTariflerPage> {
  List<Map<String, dynamic>> _videolar = [];
  bool _isLoading = true;
  int? _selectedIndex;
  String? _currentVideoId;
  InAppWebViewController? _webViewController;
  bool _webViewReady = false;

  static const _userAgent =
      'Mozilla/5.0 (Linux; Android 11; Pixel 5) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/119.0.6045.163 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    _loadVideolar();
  }

  Future<void> _loadVideolar() async {
    try {
      final response = await SupabaseConfig.client
          .from('videolu_tarifler')
          .select()
          .order('created_at');
      if (mounted) {
        setState(() {
          _videolar = List<Map<String, dynamic>>.from(response as List);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _videolar = [
            {'baslik': 'Menemen Tarifi', 'video_id': 'ajdSDri1c-U'},
            {'baslik': 'Kuru Fasulye Tarifi', 'video_id': '7rORG0W31aE'},
          ];
          _isLoading = false;
        });
      }
    }
  }

  void _playVideo(int index) {
    final videoId = _videolar[index]['video_id'] as String;
    final url = 'https://www.youtube.com/embed/$videoId'
        '?autoplay=1&playsinline=1&rel=0&fs=1';

    setState(() {
      _selectedIndex = index;
      _currentVideoId = videoId;
    });

    if (_webViewReady && _webViewController != null) {
      _webViewController!.loadUrl(
        urlRequest: URLRequest(url: WebUri(url)),
      );
    }
  }

  String _blankHtml() => '''<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>* { margin:0; padding:0; } body { background:#000; }</style>
</head>
<body></body>
</html>''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videolu Tarifler',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // ── Video oynatıcı ──────────────────────────────────────────
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                // WebView her zaman ağaçta kalıyor
                InAppWebView(
                  initialData: InAppWebViewInitialData(
                    data: _blankHtml(),
                    mimeType: 'text/html',
                    encoding: 'utf-8',
                    baseUrl: WebUri('https://www.youtube.com'),
                  ),
                  initialSettings: InAppWebViewSettings(
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                    javaScriptEnabled: true,
                    transparentBackground: false,
                    supportZoom: false,
                    useWideViewPort: true,
                    loadWithOverviewMode: true,
                    userAgent: _userAgent,
                    allowsAirPlayForMediaPlayback: true,
                    allowsPictureInPictureMediaPlayback: true,
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                    setState(() => _webViewReady = true);
                    // Eğer zaten bir video seçildiyse yükle
                    if (_currentVideoId != null) {
                      final url =
                          'https://www.youtube.com/embed/$_currentVideoId'
                          '?autoplay=1&playsinline=1&rel=0&fs=1';
                      controller.loadUrl(
                          urlRequest: URLRequest(url: WebUri(url)));
                    }
                  },
                ),

                // Video seçilmemişse üstünde placeholder göster
                if (_currentVideoId == null)
                  Container(
                    color: Colors.black,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_outline,
                              color: Colors.white54, size: 56),
                          SizedBox(height: 8),
                          Text('Bir tarif seçin',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Video listesi ───────────────────────────────────────────
          if (_isLoading)
            const Expanded(
                child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: _videolar.length,
                itemBuilder: (context, index) {
                  final video = _videolar[index];
                  final videoId = video['video_id'] as String;
                  final baslik = video['baslik'] as String;
                  final isSelected = _selectedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _playVideo(index),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade200,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(13)),
                              child: Image.network(
                                'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
                                width: 120,
                                height: 76,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 120,
                                  height: 76,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.video_library,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                baslik,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                isSelected
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
