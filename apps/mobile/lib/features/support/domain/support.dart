import 'package:flutter/foundation.dart';
import 'package:jarina_core/jarina_core.dart';

enum ChatAuthor { me, agent, system }

@immutable
class ChatMessage {
  const ChatMessage({required this.author, required this.text, required this.at, this.agentName});

  final ChatAuthor author;
  final String text;
  final DateTime at;
  final String? agentName;
}

/// Support's own copy for a chat language. It comes from the support desk,
/// not the app's ARB files, because agents reply in the language the user
/// picks in the chat, which can differ from the app language.
@immutable
class SupportCopy {
  const SupportCopy({
    required this.greeting,
    required this.topics,
    required this.placeholder,
    required this.online,
    required this.chattingIn,
    required this.securityNote,
  });

  final String greeting;

  /// Quick topics: id → label.
  final Map<String, String> topics;
  final String placeholder;
  final String online;
  final String chattingIn;
  final String securityNote;
}

abstract interface class SupportRepository {
  /// Chat languages: `en`, `ha`, `fr`.
  SupportCopy copy(String language);

  /// The conversation so far, oldest first. Starts with the agent's greeting.
  Stream<List<ChatMessage>> watch(String language);

  /// Sends a message; an agent replies shortly. [topic] is a quick-topic id.
  Future<Result<void>> send(String text, {required String language, String? topic});

  /// Notes the language switch in the thread.
  void switchLanguage(String language);

  /// True while an agent is typing.
  Stream<bool> watchTyping();
}
