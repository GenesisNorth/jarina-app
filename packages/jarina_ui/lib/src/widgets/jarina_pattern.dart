import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum PatternInk { gold, black }

/// The tileable African line pattern, painted behind [child] at [opacity].
///
/// The SVG tile is rasterised once per ink/scale and cached, then repeated —
/// far cheaper than drawing vector paths across a whole card every frame.
/// Design rule: dark brand surfaces only, never behind body text.
class JPattern extends StatefulWidget {
  const JPattern({required this.child, super.key, this.ink = PatternInk.gold, this.opacity = 0.16, this.tile = 84});

  final Widget child;
  final PatternInk ink;
  final double opacity;

  /// Logical size of one tile.
  final double tile;

  @override
  State<JPattern> createState() => _JPatternState();
}

class _JPatternState extends State<JPattern> {
  static final _cache = <String, Future<ui.Image>>{};
  ui.Image? _image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(JPattern old) {
    super.didUpdateWidget(old);
    if (old.ink != widget.ink || old.tile != widget.tile) unawaited(_load());
  }

  Future<void> _load() async {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final px = (widget.tile * dpr).round();
    final key = '${widget.ink.name}@$px';
    final image = await _cache.putIfAbsent(key, () => _rasterise(widget.ink, px));
    if (mounted) setState(() => _image = image);
  }

  static Future<ui.Image> _rasterise(PatternInk ink, int px) async {
    final info = await vg.loadPicture(
      SvgAssetLoader('packages/jarina_ui/assets/patterns/jarina-african-pattern-${ink.name}.svg'),
      null,
    );
    final recorder = ui.PictureRecorder();
    final scale = px / info.size.width;
    ui.Canvas(recorder)
      ..scale(scale)
      ..drawPicture(info.picture);
    info.picture.dispose();
    return recorder.endRecording().toImage(px, px);
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null) return widget.child;
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _RawImageProvider(image),
          repeat: ImageRepeat.repeat,
          alignment: Alignment.topLeft,
          scale: MediaQuery.devicePixelRatioOf(context),
          opacity: widget.opacity,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Wraps an already-decoded [ui.Image] so it can be used in a DecorationImage.
@immutable
class _RawImageProvider extends ImageProvider<_RawImageProvider> {
  const _RawImageProvider(this.image);

  final ui.Image image;

  @override
  Future<_RawImageProvider> obtainKey(ImageConfiguration configuration) => SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(_RawImageProvider key, ImageDecoderCallback decode) =>
      OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image.clone())));

  @override
  bool operator ==(Object other) => other is _RawImageProvider && other.image == image;

  @override
  int get hashCode => image.hashCode;
}
