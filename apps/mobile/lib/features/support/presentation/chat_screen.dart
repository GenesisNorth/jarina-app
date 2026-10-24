import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/payments/presentation/payments_widgets.dart';
import 'package:jarina/features/support/domain/support.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Support chat in English, Hausa or French, independent of the app language.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String? _lang;
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late Stream<List<ChatMessage>> _messages;
  late Stream<bool> _typing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lang == null) {
      final app = Localizations.localeOf(context).languageCode;
      _lang = const {'en', 'ha', 'fr'}.contains(app) ? app : 'en';
      final repo = ref.read(supportRepositoryProvider);
      _messages = repo.watch(_lang!);
      _typing = repo.watchTyping();
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) {
      unawaited(
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        ),
      );
    }
  });

  Future<void> _send(String text, {String? topic}) async {
    if (text.trim().isEmpty) return;
    _input.clear();
    setState(() {});
    _toBottom();
    await ref.read(supportRepositoryProvider).send(text, language: _lang!, topic: topic);
    _toBottom();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final repo = ref.watch(supportRepositoryProvider);
    final copy = repo.copy(_lang!);
    final time = DateFormat.Hm();

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, ''),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _messages,
              builder: (context, snap) {
                final msgs = snap.data ?? const <ChatMessage>[];
                return StreamBuilder<bool>(
                  stream: _typing,
                  builder: (context, typing) => ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 0, SpacingTokens.screenGutter, 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                const PersonAvatar(name: 'Aisha', color: 0xFFFBE9DC),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 11,
                                    height: 11,
                                    decoration: BoxDecoration(
                                      color: c.up,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: c.bg, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.jarinaSupport, style: t.body.copyWith(fontWeight: FontWeight.w700)),
                                  Text(copy.online, style: t.caption.copyWith(color: c.muted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(copy.chattingIn, style: t.caption.copyWith(color: c.muted)),
                            ),
                            for (final code in const ['en', 'ha', 'fr']) ...[
                              const SizedBox(width: 6),
                              JChip(
                                label: code.toUpperCase(),
                                selected: code == _lang,
                                onTap: () {
                                  if (code == _lang) return;
                                  setState(() => _lang = code);
                                  repo.switchLanguage(code);
                                  _toBottom();
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: c.line),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            JarinaIcon(JIcon.lock, size: 14, color: c.muted),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(copy.securityNote, style: t.caption.copyWith(color: c.muted, height: 1.4)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final m in msgs) _Bubble(message: m, time: time.format(m.at)),
                      if (typing.data ?? false)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Semantics(
                            label: l.agentTyping,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16)),
                              child: Text('•••', style: t.body.copyWith(color: c.muted, letterSpacing: 2)),
                            ),
                          ),
                        ),
                      if (msgs.length < 2)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final e in copy.topics.entries)
                              JChip(
                                label: e.value,
                                onTap: () => unawaited(_send(e.value, topic: e.key)),
                              ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.card,
              border: Border(top: BorderSide(color: c.line)),
            ),
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: l.attachScreenshot,
                    onPressed: () => showToast(context, l.attachScreenshot),
                    icon: const JarinaIcon(JIcon.plus, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (v) => unawaited(_send(v)),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: copy.placeholder,
                        semanticCounterText: l.messageLabel,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(999)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: l.sendMessage,
                    style: IconButton.styleFrom(backgroundColor: c.black, foregroundColor: Colors.white),
                    onPressed: _input.text.trim().isEmpty ? null : () => unawaited(_send(_input.text)),
                    icon: const JarinaIcon(JIcon.arrowRight, size: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.time});

  final ChatMessage message;
  final String time;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final m = message;
    if (m.author == ChatAuthor.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          m.text,
          textAlign: TextAlign.center,
          style: t.caption.copyWith(color: c.muted),
        ),
      );
    }
    final me = m.author == ChatAuthor.me;
    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(
            color: me ? c.black : c.card,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(me ? 16 : 4),
              bottomRight: Radius.circular(me ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.text, style: t.body.copyWith(color: me ? Colors.white : c.ink, height: 1.4)),
              const SizedBox(height: 4),
              Text(
                me ? '$time ✓✓' : '${m.agentName ?? ''} · $time',
                style: t.caption.copyWith(color: me ? Colors.white60 : c.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
