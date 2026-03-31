import '../../domain/entities/tarif.dart';

class TarifModel extends Tarif {
  const TarifModel({
    required super.isim,
    super.resim,
    super.kategori,
  });

  factory TarifModel.fromMap(Map<String, dynamic> map) {
    return TarifModel(
      isim: map['isim'] as String? ?? '',
      resim: map['resim'] as String?,
      kategori: map['kategori'] as String?,
    );
  }
}
