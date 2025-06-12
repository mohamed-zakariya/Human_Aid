import 'package:mobileapp/generated/l10n.dart';

class ExerciseObject {
  final String key;
  final String englishName;
  final String arabicName;
  final List<String> detectionLabels; // Labels that the model might return

  ExerciseObject({
    required this.key,
    required this.englishName,
    required this.arabicName,
    required this.detectionLabels,
  });

  String getLocalizedName(S localizations) {
    switch (key) {
      case 'spoon':
        return localizations.spoon;
      case 'book':
        return localizations.book;
      case 'cup':
        return localizations.cup;
      case 'pen':
        return localizations.pen;
      case 'fork':
        return localizations.fork;
      case 'plate':
        return localizations.plate;
      default:
        return englishName;
    }
  }
}