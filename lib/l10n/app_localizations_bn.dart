// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get hello => 'হ্যালো! 👋';

  @override
  String get findAService => 'সেবা খুঁজুন';

  @override
  String get searchHint => 'সেবা অনুসন্ধান করুন...';

  @override
  String get serviceCategories => 'সেবার ধরন';

  @override
  String get seeAll => 'সবগুলো দেখুন';

  @override
  String get topRatedProfessionals => 'সেরা পেশাদারগণ';

  @override
  String get available => 'উপলব্ধ';

  @override
  String get busy => 'ব্যস্ত';

  @override
  String reviews(int count) {
    return '$countটি রিভিউ';
  }

  @override
  String get home => 'হোম';

  @override
  String get videos => 'ভিডিও';

  @override
  String get profile => 'প্রোফাইল';

  @override
  String get categoryPlumber => 'প্লাম্বার';

  @override
  String get categoryAcRepair => 'এসি মেরামত';

  @override
  String get categoryElectrician => 'ইলেকট্রিশিয়ান';

  @override
  String get categoryPainter => 'রঙমিস্ত্রি';

  @override
  String get categoryCleaning => 'পরিষ্কার';

  @override
  String get categoryCarpenter => 'কাঠমিস্ত্রি';

  @override
  String get categoryMovers => 'পরিবহন';

  @override
  String get categoryAppliance => 'যন্ত্রপাতি';

  @override
  String get yourProfile => 'আপনার প্রোফাইল';

  @override
  String get language => 'ভাষা';

  @override
  String get english => 'English';

  @override
  String get bengali => 'বাংলা';

  @override
  String get settings => 'সেটিংস';

  @override
  String get notifications => 'বিজ্ঞপ্তি';

  @override
  String get darkMode => 'ডার্ক মোড';

  @override
  String get helpAndSupport => 'সাহায্য ও সহায়তা';

  @override
  String get logOut => 'লগ আউট';

  @override
  String get appName => 'সার্ভিসহাব';

  @override
  String get perHour => '/ঘন্টা';

  @override
  String get perVisit => '/ভিজিট';

  @override
  String yrsExp(int years) {
    return '$years বছরের অভিজ্ঞতা';
  }
}
