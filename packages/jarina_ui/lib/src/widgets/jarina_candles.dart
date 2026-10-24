import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jarina_ui/src/theme/jarina_theme.dart';

/// One OHLC bar with volume.
@immutable
class Candle {
  const Candle(this.open, this.high, this.low, this.close, this.volume);

  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  bool get up => close >= open;
}

/// Candlestick chart with MA7/MA25 lines and a volume strip. Dragging selects
/// a candle and reports it through [onInspect] (null when released).
class JCandleChart extends StatefulWidget {
  const JCandleChart({
    required this.candles,
    super.key,
    this.showMa = true,
    this.height = 240,
    this.onInspect,
    this.lineMode = false,
  });

  final List<Candle> candles;
  final bool showMa;
  final double height;
  final ValueChanged<int?>? onInspect;

  /// Draws a close-price line instead of candles.
  final bool lineMode;

  @override
  State<JCandleChart> createState() => _JCandleChartState();
}

class _JCandleChartState extends State<JCandleChart> {
  int? _selected;

  void _select(Offset p, double width) {
    final n = widget.candles.length;
    if (n == 0) return;
    final i = (p.dx / width * n).floor().clamp(0, n - 1);
    if (i != _selected) {
      setState(() => _selected = i);
      widget.onInspect?.call(i);
    }
  }

  void _clear() {
    setState(() => _selected = null);
    widget.onInspect?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Price chart',
      child: LayoutBuilder(
        builder: (context, box) => GestureDetector(
          onHorizontalDragStart: (d) => _select(d.localPosition, box.maxWidth),
          onHorizontalDragUpdate: (d) => _select(d.localPosition, box.maxWidth),
          onHorizontalDragEnd: (_) => _clear(),
          onTapDown: (d) => _select(d.localPosition, box.maxWidth),
          onTapUp: (_) => _clear(),
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(box.maxWidth, widget.height),
              painter: _CandlePainter(
                candles: widget.candles,
                up: c.up,
                down: c.down,
                grid: c.line,
                ma7: c.goldDeep,
                ma25: const Color(0xFF3C6FD8),
                text: c.muted,
                showMa: widget.showMa,
                selected: _selected,
                lineMode: widget.lineMode,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple moving average; null until [n] points are available.
List<double?> movingAverage(List<double> v, int n) => List.generate(
  v.length,
  (i) => i + 1 < n ? null : v.sublist(i + 1 - n, i + 1).reduce((a, b) => a + b) / n,
);

class _CandlePainter extends CustomPainter {
  _CandlePainter({
    required this.candles,
    required this.up,
    required this.down,
    required this.grid,
    required this.ma7,
    required this.ma25,
    required this.text,
    required this.showMa,
    required this.selected,
    required this.lineMode,
  });

  final List<Candle> candles;
  final Color up;
  final Color down;
  final Color grid;
  final Color ma7;
  final Color ma25;
  final Color text;
  final bool showMa;
  final int? selected;
  final bool lineMode;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;
    final volH = size.height * 0.16;
    final priceH = size.height - volH - 6;
    final hi = candles.map((c) => c.high).reduce(math.max);
    final lo = candles.map((c) => c.low).reduce(math.min);
    final span = hi - lo == 0 ? 1 : hi - lo;
    final maxVol = candles.map((c) => c.volume).reduce(math.max);
    final w = size.width / candles.length;
    double y(double v) => 4 + (1 - (v - lo) / span) * (priceH - 8);

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 0.6;
    for (var i = 0; i <= 3; i++) {
      final gy = priceH * i / 3;
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), gridPaint);
    }

    if (lineMode) {
      final path = Path();
      for (var i = 0; i < candles.length; i++) {
        final p = Offset(i * w + w / 2, y(candles[i].close));
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = ma7
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }

    for (var i = 0; i < candles.length; i++) {
      final k = candles[i];
      final color = k.up ? up : down;
      final x = i * w + w / 2;
      final paint = Paint()..color = color.withValues(alpha: selected == null || selected == i ? 1 : 0.55);
      if (!lineMode) {
        canvas.drawLine(Offset(x, y(k.high)), Offset(x, y(k.low)), paint..strokeWidth = 1);
        final top = y(math.max(k.open, k.close));
        final bottom = math.max(y(math.min(k.open, k.close)), top + 1);
        canvas.drawRect(Rect.fromLTRB(x - w * 0.32, top, x + w * 0.32, bottom), paint);
      }
      final vh = maxVol == 0 ? 0.0 : k.volume / maxVol * volH;
      canvas.drawRect(
        Rect.fromLTRB(x - w * 0.32, size.height - vh, x + w * 0.32, size.height),
        Paint()..color = color.withValues(alpha: 0.35),
      );
    }

    if (showMa) {
      final closes = candles.map((c) => c.close).toList();
      for (final (n, color) in [(7, ma7), (25, ma25)]) {
        final ma = movingAverage(closes, n);
        final path = Path();
        var started = false;
        for (var i = 0; i < ma.length; i++) {
          final v = ma[i];
          if (v == null) continue;
          final p = Offset(i * w + w / 2, y(v));
          started ? path.lineTo(p.dx, p.dy) : path.moveTo(p.dx, p.dy);
          started = true;
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3,
        );
      }
    }

    final s = selected;
    if (s != null) {
      final x = s * w + w / 2;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = text
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(_CandlePainter old) =>
      !identical(old.candles, candles) || old.selected != selected || old.showMa != showMa || old.lineMode != lineMode;
}
