import 'package:flutter/material.dart';
import 'package:bockaire/l10n/app_localizations.dart';

enum SupportedLanguage {
  en('en', 'English'),
  de('de', 'German'),
  zh('zh', 'Chinese'),
  // EU Languages
  fr('fr', 'French'),
  es('es', 'Spanish'),
  it('it', 'Italian'),
  pt('pt', 'Portuguese'),
  nl('nl', 'Dutch'),
  pl('pl', 'Polish'),
  el('el', 'Greek'),
  cs('cs', 'Czech'),
  hu('hu', 'Hungarian'),
  ro('ro', 'Romanian'),
  sv('sv', 'Swedish'),
  da('da', 'Danish'),
  fi('fi', 'Finnish'),
  sk('sk', 'Slovak'),
  bg('bg', 'Bulgarian'),
  hr('hr', 'Croatian'),
  lt('lt', 'Lithuanian'),
  lv('lv', 'Latvian'),
  sl('sl', 'Slovenian'),
  et('et', 'Estonian'),
  mt('mt', 'Maltese'),
  ga('ga', 'Irish'),
  // Middle East Languages
  ar('ar', 'Arabic'),
  tr('tr', 'Turkish'),
  he('he', 'Hebrew'),
  fa('fa', 'Persian');

  const SupportedLanguage(this.code, this.name);
  final String code;
  final String name;

  static final Map<String, SupportedLanguage> _byCode = {
    for (var lang in values) lang.code: lang,
  };

  static SupportedLanguage? fromCode(String code) {
    return _byCode[code];
  }

  String localizedName(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return switch (this) {
      SupportedLanguage.en => localizations.languageEnglish,
      SupportedLanguage.de => localizations.languageGerman,
      SupportedLanguage.zh => localizations.languageChinese,
      SupportedLanguage.fr => localizations.languageFrench,
      SupportedLanguage.es => localizations.languageSpanish,
      SupportedLanguage.it => localizations.languageItalian,
      SupportedLanguage.pt => localizations.languagePortuguese,
      SupportedLanguage.nl => localizations.languageDutch,
      SupportedLanguage.pl => localizations.languagePolish,
      SupportedLanguage.el => localizations.languageGreek,
      SupportedLanguage.cs => localizations.languageCzech,
      SupportedLanguage.hu => localizations.languageHungarian,
      SupportedLanguage.ro => localizations.languageRomanian,
      SupportedLanguage.sv => localizations.languageSwedish,
      SupportedLanguage.da => localizations.languageDanish,
      SupportedLanguage.fi => localizations.languageFinnish,
      SupportedLanguage.sk => localizations.languageSlovak,
      SupportedLanguage.bg => localizations.languageBulgarian,
      SupportedLanguage.hr => localizations.languageCroatian,
      SupportedLanguage.lt => localizations.languageLithuanian,
      SupportedLanguage.lv => localizations.languageLatvian,
      SupportedLanguage.sl => localizations.languageSlovenian,
      SupportedLanguage.et => localizations.languageEstonian,
      SupportedLanguage.mt => localizations.languageMaltese,
      SupportedLanguage.ga => localizations.languageIrish,
      SupportedLanguage.ar => localizations.languageArabic,
      SupportedLanguage.tr => localizations.languageTurkish,
      SupportedLanguage.he => localizations.languageHebrew,
      SupportedLanguage.fa => localizations.languagePersian,
    };
  }
}
