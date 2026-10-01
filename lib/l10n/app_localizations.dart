import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
    Locale('bn'),
    Locale('en')
  ];

  /// Greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Hello! 👋'**
  String get hello;

  /// Home screen headline
  ///
  /// In en, this message translates to:
  /// **'Find a Service'**
  String get findAService;

  /// Search bar placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search for a service...'**
  String get searchHint;

  /// Section title for categories
  ///
  /// In en, this message translates to:
  /// **'Service Categories'**
  String get serviceCategories;

  /// Button to see all items
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Section title for professionals list
  ///
  /// In en, this message translates to:
  /// **'Top Rated Professionals'**
  String get topRatedProfessionals;

  /// Professional availability status
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Professional busy status
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// Review count text
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviews(int count);

  /// Bottom nav label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Bottom nav label
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// Bottom nav label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Service category
  ///
  /// In en, this message translates to:
  /// **'Plumber'**
  String get categoryPlumber;

  /// Service category
  ///
  /// In en, this message translates to:
  /// **'AC Repair'**
  String get categoryAcRepair;

  /// Service category
  ///
  /// In en, this message translates to:
  /// **'Electrician'**
  String get categoryElectrician;

  /// Service category
  ///
  /// In en, this message translates to:
  /// **'Painter'**
  String get categoryPainter;

  /// Service category
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get categoryCleaning;

  /// Service category
  ///
  /// In en, this message translates to:
  /// **'Carpenter'**
  String get categoryCarpenter;

  /// Service category
  ///
  /// In en, this message translates to:
  /// **'Movers'**
  String get categoryMovers;

  /// Service category
  ///
  /// In en, this message translates to:
  /// **'Appliance'**
  String get categoryAppliance;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// Language section title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Bengali language name
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bengali;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Dark mode toggle
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Help menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Utsho'**
  String get appName;

  /// Per hour rate suffix
  ///
  /// In en, this message translates to:
  /// **'/hr'**
  String get perHour;

  /// Per visit rate suffix
  ///
  /// In en, this message translates to:
  /// **'/visit'**
  String get perVisit;

  /// Years of experience
  ///
  /// In en, this message translates to:
  /// **'{years} yrs exp'**
  String yrsExp(int years);
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
