import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/kilo_kaydi.dart';

const _aylar = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

String kisaTarih(DateTime d) => '${d.day} ${_aylar[d.month - 1]}';
String uzunTarih(DateTime d) => '${d.day} ${_aylar[d.month - 1]} ${d.year}';
String kgMetni(double kg) => '${kg.toStringAsFixed(1)} kg';

/// Zamana göre kilo değişimi çizgi grafiği (tek seri).
///
/// Dokun / yatay sürükle → en yakın ölçüm için dikey çizgi + değer balonu.
class KiloGrafik extends StatefulWidget {
  const KiloGrafik({super.key, required this.kayitlar, this.height = 200});

  /// Eskiden yeniye sıralı, en az 2 kayıt.
  final List<KiloKaydi> kayitlar;
  final double height;

  @override
  State<KiloGrafik> createState() => _KiloGrafikState();
}

class _KiloGrafikState extends State<KiloGrafik> {
  int? _active;

  void _hit(Offset local, Size size) {
    final layout = _Layout(widget.kayitlar, size);
    var best = 0;
    var bestDx = double.infinity;
    for (var i = 0; i < widget.kayitlar.length; i++) {
      final dx = (layout.x(i) - local.dx).abs();
      if (dx < bestDx) {
        bestDx = dx;
        best = i;
      }
    }
    if (_active != best) setState(() => _active = best);
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kayitlar;
    final kilolar = k.map((e) => e.kilo);
    final ozet =
        'Kilo grafiği: ${uzunTarih(k.first.tarih)} tarihinde '
        '${kgMetni(k.first.kilo)}, ${uzunTarih(k.last.tarih)} tarihinde '
        '${kgMetni(k.last.kilo)}. En düşük ${kgMetni(kilolar.reduce(math.min))}, '
        'en yüksek ${kgMetni(kilolar.reduce(math.max))}.';

    return Semantics(
      label: ozet,
      excludeSemantics: true,
      child: SizedBox(
        height: widget.height,
        child: LayoutBuilder(
          builder: (context, c) {
            final size = Size(c.maxWidth, widget.height);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _hit(d.localPosition, size),
              onHorizontalDragStart: (d) => _hit(d.localPosition, size),
              onHorizontalDragUpdate: (d) => _hit(d.localPosition, size),
              onHorizontalDragEnd: (_) => setState(() => _active = null),
              onLongPressEnd: (_) => setState(() => _active = null),
              child: CustomPaint(
                size: size,
                painter: _KiloPainter(
                  kayitlar: k,
                  active: _active,
                  theme: Theme.of(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Eksen ölçekleri ve piksel dönüşümleri.
class _Layout {
  _Layout(this.k, this.size) {
    final minK = k.map((e) => e.kilo).reduce(math.min);
    final maxK = k.map((e) => e.kilo).reduce(math.max);
    var lo = minK - 1;
    var hi = maxK + 1;
    step = [
      1.0,
      2.0,
      5.0,
      10.0,
      20.0,
      50.0,
    ].firstWhere((s) => (hi - lo) / s <= 4, orElse: () => 100);
    lo = (lo / step).floor() * step;
    hi = (hi / step).ceil() * step;
    if (hi - lo < step * 2) hi = lo + step * 2;
    yMin = lo;
    yMax = hi;

    t0 = k.first.tarih.millisecondsSinceEpoch.toDouble();
    span = k.last.tarih.millisecondsSinceEpoch - t0;
  }

  static const left = 40.0;
  static const right = 14.0;
  static const top = 30.0;
  static const bottom = 24.0;

  final List<KiloKaydi> k;
  final Size size;
  late final double step, yMin, yMax, t0, span;

  Rect get plot =>
      Rect.fromLTRB(left, top, size.width - right, size.height - bottom);

  double x(int i) {
    // Tüm ölçümler aynı andaysa sıraya göre eşit dağıt
    final f = span <= 0
        ? (k.length == 1 ? 0.5 : i / (k.length - 1))
        : (k[i].tarih.millisecondsSinceEpoch - t0) / span;
    return plot.left + f * plot.width;
  }

  double y(double kg) =>
      plot.bottom - (kg - yMin) / (yMax - yMin) * plot.height;
}

class _KiloPainter extends CustomPainter {
  _KiloPainter({
    required this.kayitlar,
    required this.active,
    required this.theme,
  });

  final List<KiloKaydi> kayitlar;
  final int? active;
  final ThemeData theme;

  ColorScheme get s => theme.colorScheme;

  void _text(
    Canvas canvas,
    String text,
    Offset at,
    TextStyle style, {
    Alignment align = Alignment.center,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = at.dx - tp.width * (align.x + 1) / 2;
    final dy = at.dy - tp.height * (align.y + 1) / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final l = _Layout(kayitlar, size);
    final plot = l.plot;
    final muted = theme.textTheme.labelSmall!.copyWith(
      color: s.onSurfaceVariant,
      fontSize: 11,
    );

    // ── Izgara + y ekseni etiketleri (soluk) ─────────────
    final grid = Paint()
      ..color = s.outlineVariant
      ..strokeWidth = 1;
    for (var v = l.yMin; v <= l.yMax + 0.001; v += l.step) {
      final y = l.y(v);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      _text(
        canvas,
        v.toStringAsFixed(0),
        Offset(plot.left - 8, y),
        muted,
        align: Alignment.centerRight,
      );
    }

    // ── x ekseni: ilk ve son tarih ───────────────────────
    final xLabelY = plot.bottom + 8;
    _text(
      canvas,
      kisaTarih(kayitlar.first.tarih),
      Offset(plot.left, xLabelY),
      muted,
      align: Alignment.topLeft,
    );
    _text(
      canvas,
      kisaTarih(kayitlar.last.tarih),
      Offset(plot.right, xLabelY),
      muted,
      align: Alignment.topRight,
    );

    // ── Çizgi + alan ─────────────────────────────────────
    final pts = [
      for (var i = 0; i < kayitlar.length; i++)
        Offset(l.x(i), l.y(kayitlar[i].kilo)),
    ];
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }
    final area = Path.from(line)
      ..lineTo(pts.last.dx, plot.bottom)
      ..lineTo(pts.first.dx, plot.bottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            s.primary.withValues(alpha: 0.18),
            s.primary.withValues(alpha: 0.0),
          ],
        ).createShader(plot),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = s.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // ── İşaretçiler (8px, 2px yüzey halkası) ─────────────
    void marker(Offset p, {double r = 4}) {
      canvas.drawCircle(p, r + 2, Paint()..color = s.surface);
      canvas.drawCircle(p, r, Paint()..color = s.primary);
    }

    final showAll = kayitlar.length <= 20;
    for (var i = 0; i < pts.length; i++) {
      if (showAll || i == pts.length - 1) marker(pts[i]);
    }

    final ink = theme.textTheme.labelMedium!.copyWith(
      color: s.onSurface,
      fontWeight: FontWeight.w700,
    );

    // ── Doğrudan etiket: son değer ───────────────────────
    if (active != pts.length - 1) {
      // Çizgi son noktaya yukarıdan iniyorsa etiket altta, aksi halde üstte
      // dursun — önceki segment/işaretçiyle çakışmasın.
      final below = pts.length > 1 && pts[pts.length - 2].dy < pts.last.dy - 2;
      final right = pts.last.dx > plot.right - 30;
      _text(
        canvas,
        kgMetni(kayitlar.last.kilo),
        pts.last.translate(0, below ? 10 : -10),
        ink,
        align: below
            ? (right ? Alignment.topRight : Alignment.topCenter)
            : (right ? Alignment.bottomRight : Alignment.bottomCenter),
      );
    }

    // ── Hover / dokunma: dikey çizgi + balon ─────────────
    final a = active;
    if (a != null) {
      final p = pts[a];
      canvas.drawLine(
        Offset(p.dx, plot.top),
        Offset(p.dx, plot.bottom),
        Paint()
          ..color = s.onSurfaceVariant.withValues(alpha: 0.5)
          ..strokeWidth = 1,
      );
      marker(p, r: 5);

      final title = TextPainter(
        text: TextSpan(text: kgMetni(kayitlar[a].kilo), style: ink),
        textDirection: TextDirection.ltr,
      )..layout();
      final sub = TextPainter(
        text: TextSpan(text: uzunTarih(kayitlar[a].tarih), style: muted),
        textDirection: TextDirection.ltr,
      )..layout();
      const pad = 8.0;
      final w = math.max(title.width, sub.width) + pad * 2;
      final h = title.height + sub.height + pad * 2;
      var left = (p.dx - w / 2).clamp(0.0, size.width - w);
      var top = p.dy - h - 12;
      if (top < 0) top = p.dy + 12;
      final box = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, w, h),
        const Radius.circular(8),
      );
      canvas.drawRRect(
        box.shift(const Offset(0, 2)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(box, Paint()..color = s.surface);
      canvas.drawRRect(
        box,
        Paint()
          ..color = s.outlineVariant
          ..style = PaintingStyle.stroke,
      );
      title.paint(canvas, Offset(left + pad, top + pad));
      sub.paint(canvas, Offset(left + pad, top + pad + title.height));
    }
  }

  @override
  bool shouldRepaint(_KiloPainter old) =>
      old.kayitlar != kayitlar || old.active != active || old.theme != theme;
}
