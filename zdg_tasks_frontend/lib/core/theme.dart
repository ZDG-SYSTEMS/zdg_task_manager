import 'package:flutter/material.dart';

/// Brand palette extracted programmatically from the supplied group
/// logo (dominant saturated pixel buckets of zdg_import.png):
/// blue #0030A0, red #F00010.
const Color brandBlue = Color(0xFF0030A0);
const Color brandRed = Color(0xFFF00010);

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: brandBlue).copyWith(
    error: brandRed,
  ),
  useMaterial3: true,
);
