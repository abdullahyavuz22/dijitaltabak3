/// Kullanıcının tek bir kilo ölçümü.
class KiloKaydi {
  final String id;
  final double kilo;
  final DateTime tarih;

  const KiloKaydi({required this.id, required this.kilo, required this.tarih});

  factory KiloKaydi.fromMap(Map<String, dynamic> map) => KiloKaydi(
    id: map['id'].toString(),
    kilo: double.parse(map['kilo'].toString()),
    tarih: DateTime.parse(map['tarih'].toString()).toLocal(),
  );
}
