// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get hello => 'Hello! 👋';

  @override
  String get findAService => 'Find a Service';

  @override
  String get searchHint => 'Search for a service...';

  @override
  String get serviceCategories => 'Service Categories';

  @override
  String get seeAll => 'See All';

  @override
  String get topRatedProfessionals => 'Top Rated Professionals';

  @override
  String get available => 'Available';

  @override
  String get busy => 'Busy';

  @override
  String reviews(int count) {
    return '$count reviews';
  }

  @override
  String get home => 'Home';

  @override
  String get videos => 'Videos';

  @override
  String get profile => 'Profile';

  @override
  String get categoryPlumber => 'Plumber';

  @override
  String get categoryAcRepair => 'AC Repair';

  @override
  String get categoryElectrician => 'Electrician';

  @override
  String get categoryPainter => 'Painter';

  @override
  String get categoryCleaning => 'Cleaning';

  @override
  String get categoryCarpenter => 'Carpenter';

  @override
  String get categoryMovers => 'Movers';

  @override
  String get categoryAppliance => 'Appliance';

  @override
  String get yourProfile => 'Your Profile';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get bengali => 'বাংলা';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get logOut => 'Log Out';

  @override
  String get appName => 'Utsho';

  @override
  String get perHour => '/hr';

  @override
  String get perVisit => '/visit';

  @override
  String yrsExp(int years) {
    return '$years yrs exp';
  }
}
