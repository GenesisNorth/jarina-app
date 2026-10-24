import 'dart:async';

import 'package:jarina/features/support/domain/support.dart';
import 'package:jarina_core/jarina_core.dart';

/// Scripted support desk from the prototype, in English, Hausa and French.
class FakeSupport implements SupportRepository {
  FakeSupport({required DateTime Function() clock, this.replyDelay = const Duration(milliseconds: 1100)})
    : _now = clock;

  final DateTime Function() _now;
  final Duration replyDelay;
  final _messages = <ChatMessage>[];
  final _c = StreamController<List<ChatMessage>>.broadcast();
  final _typing = StreamController<bool>.broadcast();
  var _isTyping = false;

  static const _copy = {
    'en': SupportCopy(
      greeting: "Hello Aminu, I'm Aisha from Jarina Support. How can I help you today?",
      topics: {
        'transfer': 'Transfer issue',
        'withdraw': 'Withdrawal delay',
        'kyc': 'Verification help',
        'access': 'Account access',
        'agent': 'Talk to an agent',
      },
      placeholder: 'Type a message',
      online: 'Online · replies in about 2 min',
      chattingIn: 'Chatting in English',
      securityNote: 'Never share your PIN or 2FA code. Jarina staff will never ask for them.',
    ),
    'ha': SupportCopy(
      greeting: 'Sannu Aminu, ni ce Aisha daga Tallafin Jarina. Ta yaya zan taimaka maka yau?',
      topics: {
        'transfer': 'Matsalar tura kuɗi',
        'withdraw': 'Jinkirin cirewa',
        'kyc': 'Taimakon tantancewa',
        'access': 'Shiga asusu',
        'agent': "Yi magana da ma'aikaci",
      },
      placeholder: 'Rubuta saƙo',
      online: 'Akan layi · yana amsawa cikin minti 2',
      chattingIn: 'Hira cikin Hausa',
      securityNote: "Kada ka taɓa bayyana PIN ko lambar 2FA ɗinka. Ma'aikatan Jarina ba za su taɓa neman su ba.",
    ),
    'fr': SupportCopy(
      greeting: "Bonjour Aminu, je suis Aïcha du support Jarina. Comment puis-je vous aider aujourd'hui ?",
      topics: {
        'transfer': 'Problème de transfert',
        'withdraw': 'Retrait en retard',
        'kyc': 'Aide à la vérification',
        'access': 'Accès au compte',
        'agent': 'Parler à un agent',
      },
      placeholder: 'Écrire un message',
      online: 'En ligne · répond en 2 min environ',
      chattingIn: 'Discussion en français',
      securityNote: "Ne partagez jamais votre PIN ou votre code 2FA. L'équipe Jarina ne vous les demandera jamais.",
    ),
  };

  static const _replies = {
    'en': {
      'transfer': "Sorry about that. Please send the 15-digit transaction ID from your receipt and I'll trace it with our payout partner right away.",
      'withdraw': 'Crypto withdrawals usually arrive within minutes. Large amounts or new addresses are reviewed first, which can take up to an hour.',
      'kyc': 'To verify you need your BVN or NIN, a clear photo of your ID and a quick selfie. If your ID was rejected, retake the photo in good light without glare.',
      'access': "For your security I can't sign you in from chat. Log in with your WhatsApp number; if you've lost your authenticator, use one of your backup codes.",
      'agent': "I'm connecting you to a support agent. Musa has joined the chat and will reply in a moment.",
      'other': "Thank you, I've noted that. An agent will reply here within a few minutes. Your reference is T-2051.",
    },
    'ha': {
      'transfer': "Mun yi haƙuri. Da fatan za ka aiko lambar ma'amala mai lambobi 15 daga rasit ɗinka, zan bi diddiginta tare da abokin biyan kuɗinmu nan take.",
      'withdraw': 'Cirewar kirifto yawanci tana isowa cikin mintuna. Manyan kuɗi ko sababbin adireshi ana duba su tukuna, wanda zai iya ɗaukar har awa ɗaya.',
      'kyc': 'Don tantancewa kana buƙatar BVN ko NIN, hoton katin shaidarka mai kyau da hoton fuska. Idan an ƙi katinka, sake ɗaukar hoto a haske mai kyau babu walƙiya.',
      'access': 'Saboda tsaronka ba zan iya shigar da kai ta nan ba. Shiga da lambar WhatsApp ɗinka; idan ka rasa manhajar tantancewa, yi amfani da ɗaya daga cikin lambobin ajiyarka.',
      'agent': "Ina haɗa ka da ma'aikacin tallafi. Musa ya shigo hirar kuma zai amsa nan ba da jimawa ba.",
      'other':
          "Na gode, na lura da hakan. Ma'aikaci zai amsa a nan cikin 'yan mintuna. Lambar bayaninka ita ce T-2051.",
    },
    'fr': {
      'transfer': "Désolée pour ce désagrément. Envoyez-moi l'ID de transaction à 15 chiffres de votre reçu et je le retrouve tout de suite avec notre partenaire de paiement.",
      'withdraw': "Les retraits crypto arrivent généralement en quelques minutes. Les montants élevés ou les nouvelles adresses sont d'abord vérifiés, ce qui peut prendre jusqu'à une heure.",
      'kyc': "Pour la vérification, il vous faut votre BVN ou NIN, une photo nette de votre pièce d'identité et un selfie. Si votre pièce a été refusée, reprenez la photo sous une bonne lumière, sans reflet.",
      'access': 'Pour votre sécurité, je ne peux pas vous connecter par chat. Connectez-vous avec votre numéro WhatsApp ; si vous avez perdu votre application 2FA, utilisez un de vos codes de secours.',
      'agent':
          'Je vous mets en relation avec un agent. Moussa a rejoint la conversation et vous répond dans un instant.',
      'other': 'Merci, c’est noté. Un agent vous répondra ici dans quelques minutes. Votre référence est T-2051.',
    },
  };

  static String _lang(String l) => _copy.containsKey(l) ? l : 'en';

  @override
  SupportCopy copy(String language) => _copy[_lang(language)]!;

  void _emit() => _c.add(List.unmodifiable(_messages));

  void _ensureGreeting(String language) {
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(author: ChatAuthor.agent, text: copy(language).greeting, at: _now(), agentName: 'Aisha'),
      );
    }
  }

  @override
  Stream<List<ChatMessage>> watch(String language) {
    _ensureGreeting(language);
    return Stream.multi((out) {
      final sub = _c.stream.listen(out.add);
      out
        ..add(List.unmodifiable(_messages))
        ..onCancel = sub.cancel;
    });
  }

  @override
  Stream<bool> watchTyping() => Stream.multi((out) {
    final sub = _typing.stream.listen(out.add);
    out
      ..add(_isTyping)
      ..onCancel = sub.cancel;
  });

  void _setTyping(bool v) {
    _isTyping = v;
    _typing.add(v);
  }

  /// Picks a canned answer from keywords in any of the three languages.
  static String classify(String text) {
    final t = text.toLowerCase();
    if (RegExp(r'\d{15}|transf|tura|envoi|virement').hasMatch(t)) return 'transfer';
    if (RegExp('withdraw|cire|retrait').hasMatch(t)) return 'withdraw';
    if (RegExp('kyc|verif|tantanc|bvn|nin').hasMatch(t)) return 'kyc';
    if (RegExp('login|log in|sign in|shiga|connexion|connecter').hasMatch(t)) return 'access';
    if (RegExp("agent|human|ma'aikaci").hasMatch(t)) return 'agent';
    return 'other';
  }

  @override
  Future<Result<void>> send(String text, {required String language, String? topic}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const Err(ValidationFailure('Type a message'));
    _ensureGreeting(language);
    _messages.add(ChatMessage(author: ChatAuthor.me, text: trimmed, at: _now()));
    _emit();
    _setTyping(true);
    final key = topic ?? classify(trimmed);
    if (replyDelay > Duration.zero) await Future<void>.delayed(replyDelay);
    _setTyping(false);
    _messages.add(
      ChatMessage(
        author: ChatAuthor.agent,
        text: _replies[_lang(language)]![key]!,
        at: _now(),
        agentName: key == 'agent' ? (language == 'fr' ? 'Moussa' : 'Musa') : (language == 'fr' ? 'Aïcha' : 'Aisha'),
      ),
    );
    _emit();
    return const Ok(null);
  }

  @override
  void switchLanguage(String language) {
    if (_messages.length < 2) {
      // Nothing said yet: just greet again in the new language.
      _messages
        ..clear()
        ..add(ChatMessage(author: ChatAuthor.agent, text: copy(language).greeting, at: _now(), agentName: 'Aisha'));
    } else {
      _messages.add(ChatMessage(author: ChatAuthor.system, text: copy(language).chattingIn, at: _now()));
    }
    _emit();
  }

  void dispose() {
    unawaited(_c.close());
    unawaited(_typing.close());
  }
}
