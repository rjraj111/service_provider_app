import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the current [ThemeMode]. Defaults to light.
/// Changing this state instantly rebuilds the MaterialApp with the new theme.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});
