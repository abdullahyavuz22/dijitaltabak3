import 'package:flutter/foundation.dart';
import '../../data/repositories/favori_repository.dart';
import '../../domain/entities/diyet.dart';
import '../../domain/entities/video.dart';

/// Uygulama genelinde paylaşılan diyet + video favorileri.
///
/// Diyetler / Videolu Tarifler sayfaları ve Favoriler sekmesi aynı
/// örneği dinler; bir yerde yapılan değişiklik her yerde görünür.
class FavoriStore extends ChangeNotifier {
  FavoriStore._();
  static final FavoriStore instance = FavoriStore._();

  final _repository = FavoriRepository();

  // id -> öğe (sıra: eklenme sırası, en yeni sonda)
  final Map<String, Diyet> _diyetler = {};
  final Map<String, Video> _videolar = {};
  bool _loading = false;

  List<Diyet> get diyetler => _diyetler.values.toList().reversed.toList();
  List<Video> get videolar => _videolar.values.toList().reversed.toList();
  bool get isLoading => _loading;

  bool isDiyetFavorite(Diyet d) => d.id != null && _diyetler.containsKey(d.id);
  bool isVideoFavorite(Video v) => v.id != null && _videolar.containsKey(v.id);

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.fetchFavoriDiyetler(),
        _repository.fetchFavoriVideolar(),
      ]);
      _diyetler
        ..clear()
        ..addEntries(
          (results[0] as List<Diyet>).reversed.map((d) => MapEntry(d.id!, d)),
        );
      _videolar
        ..clear()
        ..addEntries(
          (results[1] as List<Video>).reversed.map((v) => MapEntry(v.id!, v)),
        );
    } catch (e) {
      debugPrint('[FavoriStore] Yükleme hatası: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Çıkış yapıldığında önceki kullanıcının favorilerini temizler.
  void clear() {
    _diyetler.clear();
    _videolar.clear();
    notifyListeners();
  }

  /// Favori durumunu değiştirir; hata olursa geri alır ve `false` döner.
  Future<bool> toggleDiyet(Diyet d) =>
      _toggle(_diyetler, d.id, d, FavoriRepository.diyetColumn);

  Future<bool> toggleVideo(Video v) =>
      _toggle(_videolar, v.id, v, FavoriRepository.videoColumn);

  Future<bool> _toggle<T>(
    Map<String, T> map,
    String? id,
    T item,
    String column,
  ) async {
    if (id == null) return false;
    final wasFavorite = map.containsKey(id);

    // Optimistik güncelleme
    wasFavorite ? map.remove(id) : map[id] = item;
    notifyListeners();

    try {
      wasFavorite
          ? await _repository.remove(column, id)
          : await _repository.add(column, id);
      return true;
    } catch (e) {
      debugPrint('[FavoriStore] DB HATASI: $e');
      wasFavorite ? map[id] = item : map.remove(id);
      notifyListeners();
      return false;
    }
  }
}
