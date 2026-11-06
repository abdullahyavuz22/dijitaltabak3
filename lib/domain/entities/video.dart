/// YouTube videolu tarif.
class Video {
  /// Veritabanı satır id'si (yerel yedek listede null olabilir).
  final String? id;
  final String baslik;

  /// YouTube video id'si.
  final String videoId;

  const Video({this.id, required this.baslik, required this.videoId});

  factory Video.fromMap(Map<String, dynamic> map) => Video(
    id: map['id']?.toString(),
    baslik: map['baslik']?.toString() ?? '',
    videoId: map['video_id']?.toString() ?? '',
  );

  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
}
