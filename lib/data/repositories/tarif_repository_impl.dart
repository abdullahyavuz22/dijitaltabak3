/*import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/tarif.dart';
import '../../domain/repositories/tarif_repository.dart';
import '../models/tarif_model.dart';
import '../sources/tarif_local_source.dart';
import '../sources/tarif_supabase_source.dart';

class TarifRepositoryImpl implements TarifRepository {
  bool get _supabaseReady {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  List<Tarif> get _localTarifler =>
      tariflerData.map((e) => TarifModel.fromMap(e)).toList();

  @override
  Future<List<Tarif>> getTarifler() async {
    if (!_supabaseReady) return _localTarifler;
    try {
      return await TarifSupabaseSource().getTarifler();
    } catch (_) {
      return _localTarifler;
    }
  }

  @override
  Future<List<Tarif>> filterByCategory(String kategori) async {
    if (kategori == 'Hepsi') return getTarifler();
    if (!_supabaseReady) {
      return _localTarifler
          .where((t) => t.kategori == kategori)
          .toList();
    }
    try {
      return await TarifSupabaseSource().filterByCategory(kategori);
    } catch (_) {
      return _localTarifler
          .where((t) => t.kategori == kategori)
          .toList();
    }
  }
}
*/