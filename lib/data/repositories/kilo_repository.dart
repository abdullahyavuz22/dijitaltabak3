import '../../core/config/supabase_config.dart';
import '../../domain/entities/kilo_kaydi.dart';

/// `kilo_takibi` tablosu — oturum sahibinin kilo kayıtları.
class KiloRepository {
  String? get _userId => SupabaseConfig.client.auth.currentUser?.id;

  /// Eskiden yeniye sıralı kayıtlar.
  Future<List<KiloKaydi>> fetch() async {
    final userId = _userId;
    if (userId == null) return [];
    final response = await SupabaseConfig.client
        .from('kilo_takibi')
        .select('id, kilo, tarih')
        .eq('user_id', userId)
        .order('tarih', ascending: true);
    return (response as List)
        .map((e) => KiloKaydi.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(double kilo, DateTime tarih) async {
    final userId = _userId;
    if (userId == null) return;
    await SupabaseConfig.client.from('kilo_takibi').insert({
      'user_id': userId,
      'kilo': kilo,
      'tarih': tarih.toUtc().toIso8601String(),
    });
  }

  Future<void> delete(String id) async {
    await SupabaseConfig.client.from('kilo_takibi').delete().eq('id', id);
  }
}
