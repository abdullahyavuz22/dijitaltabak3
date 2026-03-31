import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoluTariflerPage extends StatefulWidget {
  const VideoluTariflerPage({super.key});

  @override
  State<VideoluTariflerPage> createState() => _VideoluTariflerPageState();
}

class _VideoluTariflerPageState extends State<VideoluTariflerPage> {
  final List<Map<String, String>> _videolar = [
    {
      'baslik': 'Menemen Tarifi',
      'videoId': 'ajdSDri1c-U',
    },
    {
      'baslik': 'Kuru Fasulye Tarifi',
      'videoId': '7rORG0W31aE',
    },
  ];

  int? _selectedIndex;
  YoutubePlayerController? _controller;

  void _loadVideo(int index) {
    final videoId = _videolar[index]['videoId']!;

    if (_controller == null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    } else {
      _controller!.load(videoId);
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Videolu Tarifler"),
        backgroundColor: const Color(0xFF68BE6D),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // Video oynatıcı alanı
          if (_controller != null)
            YoutubePlayer(
              controller: _controller!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: const Color(0xFF68BE6D),
            )
          else
            Container(
              color: Colors.black,
              width: double.infinity,
              height: 220,
              child: const Center(
                child: Text(
                  "Bir tarif seçin",
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Tarif listesi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _videolar.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => _loadVideo(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF68BE6D).withValues(alpha: 0.15)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF68BE6D)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: const Color(0xFF68BE6D),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _videolar[index]['baslik']!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
