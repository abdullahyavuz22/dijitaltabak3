/*import '../../core/config/supabase_config.dart';
import '../models/tarif_model.dart';

class TarifSupabaseSource {
  Future<List<TarifModel>> getTarifler() async {
    final response = await SupabaseConfig.client
        .from('tarifler')
        .select();
    return (response as List)
        .map((e) => TarifModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TarifModel>> filterByCategory(String kategori) async {
    final response = await SupabaseConfig.client
        .from('tarifler')
        .select()
        .eq('kategori', kategori);
    return (response as List)
        .map((e) => TarifModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
*/