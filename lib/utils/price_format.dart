/// Formats a price value for display.
/// - Whole numbers are shown without decimals: 30.0 → "30"
/// - Decimal numbers are shown with up to 2 significant decimal places: 5.5 → "5.5", 5.55 → "5.55"
String fmtPrice(double v) {
  if (v == v.truncateToDouble()) return v.toInt().toString();
  // Show up to 2 decimal places, strip trailing zeros
  final s = v.toStringAsFixed(2);
  return s.endsWith('0') ? s.substring(0, s.length - 1) : s;
}
