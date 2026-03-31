import '../entities/tarif.dart';
import '../repositories/tarif_repository.dart';

class FilterTarifler {
  final TarifRepository repository;

  FilterTarifler(this.repository);

  List<Tarif> byCategory(String kategori) =>
      repository.filterByCategory(kategori);
}
