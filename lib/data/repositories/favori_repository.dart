import '../../core/config/supabase_config.dart';
import '../../domain/entities/diyet.dart';
import '../../domain/entities/video.dart';

/// Diyet ve video favorileri (`favoriler.diyet_id` / `favoriler.video_id`).
/// Tarif favorileri `RecipeRepository` içindedir.
class FavoriRepository {
  static const diyetColumn = 'diyet_id';
  static const videoColumn = 'video_id';

  String? get _userId => SupabaseConfig.client.auth.currentUser?.id;

  Future<Set<String>> _fetchIds(String column) async {
    final userId = _userId;
    if (userId == null) return {};
    final response = await SupabaseConfig.client
        .from('favoriler')
        .select(column)
        .eq('user_id', userId)
        .not(column, 'is', null);
    return (response as List).map((e) => e[column].toString()).toSet();
  }

  Future<void> add(String column, String id) async {
    final userId = _userId;
    if (userId == null) return;
    await SupabaseConfig.client.from('favoriler').insert({
      column: id,
      'user_id': userId,
    });
  }

  Future<void> remove(String column, String id) async {
    final userId = _userId;
    if (userId == null) return;
    await SupabaseConfig.client
        .from('favoriler')
        .delete()
        .eq(column, id)
        .eq('user_id', userId);
  }

  /// Kullanıcının favori diyetleri (en yeni önce).
  Future<List<Diyet>> fetchFavoriDiyetler() async {
    final ids = await _fetchIds(diyetColumn);
    if (ids.isEmpty) return [];
    final response = await SupabaseConfig.client
        .from('diyet_planlari')
        .select()
        .inFilter('id', ids.toList())
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => Diyet.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Kullanıcının favori videoları.
  Future<List<Video>> fetchFavoriVideolar() async {
    final ids = await _fetchIds(videoColumn);
    if (ids.isEmpty) return [];
    final response = await SupabaseConfig.client
        .from('videolu_tarifler')
        .select()
        .inFilter('id', ids.toList())
        .order('created_at');
    return (response as List)
        .map((e) => Video.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
