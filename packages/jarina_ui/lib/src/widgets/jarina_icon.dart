import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jarina_ui/src/theme/jarina_theme.dart';

/// The 47 line icons from the prototype plus arrows (24×24, 1.8px stroke).
enum JIcon {
  activity,
  arrowLeft,
  arrowRight,
  airtime,
  auto,
  back,
  bank,
  bell,
  bolt,
  cable,
  camera,
  check,
  chev,
  copy,
  crypto,
  data,
  device,
  doc,
  down,
  eye,
  face,
  finger,
  globe,
  help,
  home,
  idcard,
  key,
  lock,
  logout,
  menu,
  moon,
  more,
  pin,
  plus,
  qr,
  receive,
  search,
  send,
  shield,
  star,
  stocks,
  sun,
  swap,
  transfer,
  trash,
  up,
  user,
  wallet,
  x;

  String get asset => 'packages/jarina_ui/assets/icons/$name.svg';
}

class JarinaIcon extends StatelessWidget {
  const JarinaIcon(this.icon, {super.key, this.size = 24, this.color, this.semanticLabel});

  final JIcon icon;
  final double size;
  final Color? color;

  /// Required when the icon is the only content of a tappable control.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    icon.asset,
    width: size,
    height: size,
    semanticsLabel: semanticLabel,
    excludeFromSemantics: semanticLabel == null,
    colorFilter: ColorFilter.mode(color ?? context.colors.ink, BlendMode.srcIn),
  );
}

/// Country flags available in the prototype.
enum JFlag {
  ng,
  ne,
  gh,
  cm,
  bj,
  tg,
  td,
  ml;

  static JFlag? fromIso(String iso) => JFlag.values.where((f) => f.name == iso.toLowerCase()).firstOrNull;

  String get asset => 'packages/jarina_ui/assets/flags/$name.svg';
}

class JarinaFlag extends StatelessWidget {
  const JarinaFlag(this.flag, {super.key, this.width = 30});

  final JFlag flag;
  final double width;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(3),
    child: SvgPicture.asset(flag.asset, width: width, height: width * 2 / 3, fit: BoxFit.cover),
  );
}
