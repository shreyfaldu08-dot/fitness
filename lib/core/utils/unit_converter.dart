class UnitConverter {
  UnitConverter._();

  static double kgToLbs(double kg) => kg * 2.20462;
  static double lbsToKg(double lbs) => lbs / 2.20462;

  static double cmToInches(double cm) => cm / 2.54;
  static double inchesToCm(double inches) => inches * 2.54;

  static (int feet, int inches) cmToFeetAndInches(double cm) {
    final totalInches = (cm / 2.54).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return (feet, inches);
  }

  static double feetAndInchesToCm(int feet, int inches) {
    final totalInches = (feet * 12) + inches;
    return totalInches * 2.54;
  }

  static double mlToFlOz(int ml) => ml * 0.033814;
  static int flOzToMl(double flOz) => (flOz / 0.033814).round();

  static String formatWeight(double kg, {bool isMetric = true}) {
    if (isMetric) {
      return '${kg.toStringAsFixed(1)} kg';
    } else {
      return '${kgToLbs(kg).toStringAsFixed(1)} lbs';
    }
  }

  static String formatHeight(double cm, {bool isMetric = true}) {
    if (isMetric) {
      return '${cm.round()} cm';
    } else {
      final (feet, inches) = cmToFeetAndInches(cm);
      return '$feet\'$inches"';
    }
  }
}
