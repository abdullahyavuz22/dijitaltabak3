import '../entities/tarif.dart';
import '../repositories/tarif_repository.dart';

class GetTarifler {
  final TarifRepository repository;

  GetTarifler(this.repository);

  List<Tarif> call() => repository.getTarifler();
}
