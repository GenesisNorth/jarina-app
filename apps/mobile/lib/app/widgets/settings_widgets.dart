import 'package:flutter/material.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// A row in More / Account: icon tile, title (and subtitle), value, chevron.
/// Pass [trailing] for a switch instead of the value and chevron.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.value,
    this.onTap,
    this.trailing,
    this.danger = false,
    this.done = false,
  });

  final JIcon icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;

  /// Shows a green check tile (verification steps).
  final bool done;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final fg = danger ? c.down : (done ? c.up : c.ink);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: danger
                      ? c.down.withValues(alpha: 0.1)
                      : done
                      ? c.up.withValues(alpha: 0.12)
                      : c.gold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: JarinaIcon(done ? JIcon.check : icon, size: 18, color: fg),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.body.copyWith(color: danger ? c.down : c.ink, fontWeight: FontWeight.w500),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(subtitle!, style: t.caption.copyWith(color: c.muted, height: 1.4)),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else ...[
                if (value != null)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        value!,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.body.copyWith(
                          color: done ? c.up : c.muted,
                          fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                          fontSize: done ? 13 : null,
                        ),
                      ),
                    ),
                  ),
                if (onTap != null) ...[
                  const SizedBox(width: 6),
                  JarinaIcon(JIcon.chev, size: 14, color: c.muted),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small grey label above a group of rows.
class SettingsLabel extends StatelessWidget {
  const SettingsLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
    child: Text(
      text,
      style: context.text.caption.copyWith(color: context.colors.muted, fontWeight: FontWeight.w600),
    ),
  );
}

/// `+234 801 234 5678` for Nigerian numbers; other numbers as given.
String formatPhone(String? e164) {
  if (e164 == null) return '';
  if (e164.startsWith('+234') && e164.length == 14) {
    final d = e164.substring(4);
    return '+234 ${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6)}';
  }
  return e164;
}
