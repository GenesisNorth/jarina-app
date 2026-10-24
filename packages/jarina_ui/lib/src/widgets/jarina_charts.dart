import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jarina_ui/src/theme/jarina_text.dart';
import 'package:jarina_ui/src/theme/jarina_theme.dart';

/// Tiny price line for list rows. Painted directly (no chart library) because
/// Home shows many at once and they repaint on every price tick.
class JSparkline extends StatelessWidget {
  const JSparkline({required this.values, required this.color, super.key, this.width = 64, this.height = 28});

  final List<double> values;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: CustomPaint(size: Size(width, height), painter: _LinePainter(values, color, fill: false, stroke: 1.6)),
    ),
  );
}

/// Area chart with a gradient fill under the line (balance card, asset detail).
class JAreaChart extends StatelessWidget {
  const JAreaChart({required this.values, required this.color, super.key, this.height = 120, this.stroke = 2});

  final List<double> values;
  final Color color;
  final double height;
  final double stroke;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _LinePainter(values, color, fill: true, stroke: stroke)),
      ),
    ),
  );
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.values, this.color, {required this.fill, required this.stroke});

  final List<double> values;
  final Color color;
  final bool fill;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final lo = values.reduce(math.min);
    final hi = values.reduce(math.max);
    final span = hi - lo == 0 ? 1 : hi - lo;
    final pad = stroke + 1;
    Offset at(int i) => Offset(
      i / (values.length - 1) * size.width,
      pad + (1 - (values[i] - lo) / span) * (size.height - pad * 2),
    );

    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      // Midpoint smoothing keeps the line soft without overshooting.
      final p0 = at(i - 1);
      final p1 = at(i);
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      line.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    line.lineTo(at(values.length - 1).dx, at(values.length - 1).dy);

    if (fill) {
      final area = Path.from(line)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.32), color.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
      );
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    if (fill) {
      final end = at(values.length - 1);
      canvas
        ..drawCircle(end, stroke * 2.6, Paint()..color = color.withValues(alpha: 0.25))
        ..drawCircle(end, stroke * 1.4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => !identical(old.values, values) || old.color != color;
}

/// `▲ 1.20%` / `▼ 0.13%` pill. Arrow always shown so colour isn't the only cue.
class JChangePill extends StatelessWidget {
  const JChangePill({required this.percent, super.key, this.onDark = false});

  final double percent;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final up = percent >= 0;
    final color = up ? c.up : c.down;
    final text = '${up ? '▲' : '▼'} ${percent.abs().toStringAsFixed(percent.abs() < 10 ? 2 : 1)}%';
    return Semantics(
      label: '${up ? 'up' : 'down'} ${percent.abs().toStringAsFixed(2)} percent',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: onDark ? 0.22 : 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: context.text.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Monogram badge for a stock (rounded square) or coin (circle).
class JAssetBadge extends StatelessWidget {
  const JAssetBadge({
    required this.label,
    required this.color,
    required this.ring,
    required this.ink,
    super.key,
    this.round = false,
    this.size = 40,
  });

  final String label;
  final Color color;
  final Color ring;
  final Color ink;
  final bool round;
  final double size;

  @override
  Widget build(BuildContext context) {
    final light = Color.lerp(color, Colors.white, round ? 0.35 : 0.28)!;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        margin: EdgeInsets.all(math.max(2, size * 0.07)),
        decoration: BoxDecoration(
          shape: round ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: round ? null : BorderRadius.circular(size * 0.3),
          gradient: round
              ? RadialGradient(center: const Alignment(-0.4, -0.5), colors: [light, color], stops: const [0, 0.7])
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [light, color],
                  stops: const [0, 0.62],
                ),
          boxShadow: [BoxShadow(color: ring, spreadRadius: math.max(2, size * 0.07))],
        ),
        alignment: Alignment.center,
        child: FittedBox(
          child: Padding(
            padding: EdgeInsets.all(size * 0.12),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontFamilyFallback: JarinaText.fallbackFamilies,
                package: 'jarina_ui',
                color: ink,
                fontWeight: FontWeight.w700,
                fontSize: size * (round ? 0.46 : 0.36),
                letterSpacing: -0.3,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
