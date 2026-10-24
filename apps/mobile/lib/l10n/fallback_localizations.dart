import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Flutter ships no Material/Cupertino strings for Hausa (`ha`). Without these
/// delegates, framework widgets (date pickers, text selection menus, back
/// button tooltips) throw "No MaterialLocalizations found" in Hausa.
///
/// Framework strings fall back to English; all Jarina copy still comes from
/// `AppLocalizations` in Hausa.
const fallbackLocalizationsDelegates = <LocalizationsDelegate<Object>>[
  _FallbackMaterialDelegate(),
  _FallbackCupertinoDelegate(),
];

const _fallbackLanguages = {'ha'};

class _FallbackMaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialDelegate();

  @override
  bool isSupported(Locale locale) => _fallbackLanguages.contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) => SynchronousFuture(const DefaultMaterialLocalizations());

  @override
  bool shouldReload(_FallbackMaterialDelegate old) => false;
}

class _FallbackCupertinoDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoDelegate();

  @override
  bool isSupported(Locale locale) => _fallbackLanguages.contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) => SynchronousFuture(const DefaultCupertinoLocalizations());

  @override
  bool shouldReload(_FallbackCupertinoDelegate old) => false;
}
