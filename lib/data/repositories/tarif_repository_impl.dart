import '../../domain/entities/tarif.dart';
import '../../domain/repositories/tarif_repository.dart';
import '../models/tarif_model.dart';
import '../sources/tarif_local_source.dart';

class TarifRepositoryImpl implements TarifRepository {
  final List<Tarif> _tarifler = tariflerData
      .map((e) => TarifModel.fromMap(e))
      .toList();

  @override
  List<Tarif> getTarifler() => _tarifler;

  @override
  List<Tarif> filterByCategory(String kategori) {
    if (kategori == 'Hepsi') return _tarifler;
    return _tarifler.where((t) => t.kategori == kategori).toList();
  }

}
