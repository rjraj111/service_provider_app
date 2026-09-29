import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the current app locale. Defaults to English.
/// Changing this state instantly rebuilds the MaterialApp with the new locale.
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('en');
});
