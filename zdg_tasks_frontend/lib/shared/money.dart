/// Money is always carried as integer minor units (ngwee) in ZMW.
/// This helper is the single place that turns ngwee into display text,
/// so amounts can never drift through doubles.
library;

/// Formats an amount in ngwee as ZMW with two decimals and thousands
/// separators, e.g. 1234567 becomes "ZMW 12,345.67".
String formatZmw(int ngwee) {
  final sign = ngwee < 0 ? '-' : '';
  final absolute = ngwee.abs();
  final kwacha = absolute ~/ 100;
  final minor = absolute % 100;

  final digits = kwacha.toString();
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      grouped.write(',');
    }
    grouped.write(digits[i]);
  }

  return '${sign}ZMW $grouped.${minor.toString().padLeft(2, '0')}';
}

/// Parses user input like "1,234.56" into integer ngwee without ever
/// passing through a double, so precision cannot drift.
int? parseZmwToNgwee(String input) {
  final cleaned = input.replaceAll(',', '').trim();
  if (cleaned.isEmpty) return null;

  final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(cleaned);
  if (match == null) return null;

  final kwacha = int.parse(match.group(1)!);
  final minorRaw = match.group(2) ?? '0';
  final minor = int.parse(minorRaw.padRight(2, '0'));

  return kwacha * 100 + minor;
}
