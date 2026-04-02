class Diyet {
  final String? id;
  final String baslik;
  final String diyetisyen;
  final String? aciklama;
  final int? kalori;
  final String? sure;

  const Diyet({
    this.id,
    required this.baslik,
    required this.diyetisyen,
    this.aciklama,
    this.kalori,
    this.sure,
  });

  factory Diyet.fromMap(Map<String, dynamic> map) {
    return Diyet(
      id: map['id']?.toString(),
      baslik: map['baslik']?.toString() ?? '',
      diyetisyen: map['diyetisyen']?.toString() ?? '',
      aciklama: map['aciklama']?.toString(),
      kalori: map['kalori'] != null
          ? int.tryParse(map['kalori'].toString())
          : null,
      sure: map['sure']?.toString(),
    );
  }
}
