import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'RM Breeding'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In fr, this message translates to:
  /// **'Pilotage de votre élevage'**
  String get tagline;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Accédez à votre exploitation'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @demoMode.
  ///
  /// In fr, this message translates to:
  /// **'Entrer en mode démonstration'**
  String get demoMode;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @herd.
  ///
  /// In fr, this message translates to:
  /// **'Cheptel'**
  String get herd;

  /// No description provided for @reproduction.
  ///
  /// In fr, this message translates to:
  /// **'Reproduction'**
  String get reproduction;

  /// No description provided for @health.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get health;

  /// No description provided for @feeding.
  ///
  /// In fr, this message translates to:
  /// **'Alimentation'**
  String get feeding;

  /// No description provided for @production.
  ///
  /// In fr, this message translates to:
  /// **'Production'**
  String get production;

  /// No description provided for @sales.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get sales;

  /// No description provided for @finance.
  ///
  /// In fr, this message translates to:
  /// **'Finances'**
  String get finance;

  /// No description provided for @alerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get alerts;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @animals.
  ///
  /// In fr, this message translates to:
  /// **'Animaux'**
  String get animals;

  /// No description provided for @pregnancies.
  ///
  /// In fr, this message translates to:
  /// **'Gestations'**
  String get pregnancies;

  /// No description provided for @milkToday.
  ///
  /// In fr, this message translates to:
  /// **'Lait du jour (L)'**
  String get milkToday;

  /// No description provided for @openAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes ouvertes'**
  String get openAlerts;

  /// No description provided for @priorityAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes prioritaires'**
  String get priorityAlerts;

  /// No description provided for @upcomingTasks.
  ///
  /// In fr, this message translates to:
  /// **'Tâches à venir'**
  String get upcomingTasks;

  /// No description provided for @noAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte, tout va bien'**
  String get noAlerts;

  /// No description provided for @noTasks.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche planifiée'**
  String get noTasks;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @tenant.
  ///
  /// In fr, this message translates to:
  /// **'Exploitation'**
  String get tenant;

  /// No description provided for @addAnimal.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un animal'**
  String get addAnimal;

  /// No description provided for @emptyHerd.
  ///
  /// In fr, this message translates to:
  /// **'Aucun animal enregistré'**
  String get emptyHerd;

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Ce module sera enrichi dans les phases suivantes.'**
  String get comingSoon;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @offline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get offline;

  /// No description provided for @online.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get online;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get loading;

  /// No description provided for @species.
  ///
  /// In fr, this message translates to:
  /// **'Référentiel'**
  String get species;

  /// No description provided for @sites.
  ///
  /// In fr, this message translates to:
  /// **'Sites'**
  String get sites;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
