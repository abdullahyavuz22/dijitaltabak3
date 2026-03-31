import '../entities/tarif.dart';

abstract class TarifRepository {
  List<Tarif> getTarifler();
  List<Tarif> filterByCategory(String kategori);
}
