import '../../core/config/supabase_config.dart';
import '../../domain/entities/diyet.dart';

/// `diyet_planlari` tablosuna erişim.
class DiyetRepository {
  Future<List<Diyet>> fetchDiyetler() async {
    final response = await SupabaseConfig.client
        .from('diyet_planlari')
        .select()
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => Diyet.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Diyet planı ekler. Sadece diyetisyen ve admin rolleri için izinlidir —
  /// yetkisi olmayan bir çağrı Supabase RLS tarafından reddedilir.
  Future<void> addDiyet({
    required String baslik,
    required String diyetisyen,
    String? aciklama,
    int? kalori,
    String? sure,
  }) async {
    await SupabaseConfig.client.from('diyet_planlari').insert({
      'baslik': baslik,
      'diyetisyen': diyetisyen,
      'aciklama': aciklama,
      'kalori': kalori,
      'sure': sure,
      'olusturan_id': SupabaseConfig.client.auth.currentUser?.id,
    });
  }
}
