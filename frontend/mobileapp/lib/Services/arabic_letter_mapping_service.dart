// lib/utils/arabic_letter_mapping.dart

class ArabicLetterMapping {
  /// Maps Arabic letters to their spoken names and variations
  static const Map<String, List<String>> _letterToSpokenNames = {
    'ا': ['الف', 'ألف', 'اليف', 'أليف', 'الِف', 'ألِف'],
    'ب': ['باء', 'بَاء', 'با', 'بـاء'],
    'ت': ['تاء', 'تَاء', 'تا', 'تـاء'],
    'ث': ['ثاء', 'ثَاء', 'ثا', 'ثـاء'],
    'ج': ['جيم', 'جِيم', 'جـيم'],
    'ح': ['حاء', 'حَاء', 'حا', 'حـاء'],
    'خ': ['خاء', 'خَاء', 'خا', 'خـاء'],
    'د': ['دال', 'دَال', 'دـال'],
    'ذ': ['ذال', 'ذَال', 'ذـال'],
    'ر': ['راء', 'رَاء', 'را', 'رـاء'],
    'ز': ['زاي', 'زَاي', 'زاى', 'زـاي'],
    'س': ['سين', 'سِين', 'سـين'],
    'ش': ['شين', 'شِين', 'شـين'],
    'ص': ['صاد', 'صَاد', 'صـاد'],
    'ض': ['ضاد', 'ضَاد', 'ضـاد'],
    'ط': ['طاء', 'طَاء', 'طا', 'طـاء'],
    'ظ': ['ظاء', 'ظَاء', 'ظا', 'ظـاء'],
    'ع': ['عين', 'عَين', 'عـين'],
    'غ': ['غين', 'غَين', 'غـين'],
    'ف': ['فاء', 'فَاء', 'فا', 'فـاء'],
    'ق': ['قاف', 'قَاف', 'قـاف'],
    'ك': ['كاف', 'كَاف', 'كـاف'],
    'ل': ['لام', 'لَام', 'لـام'],
    'م': ['ميم', 'مِيم', 'مـيم'],
    'ن': ['نون', 'نُون', 'نـون'],
    'ه': ['هاء', 'هَاء', 'ها', 'هـاء'],
    'و': ['واو', 'وَاو', 'وـاو'],
    'ي': ['ياء', 'يَاء', 'يا', 'يـاء'],
  };

  /// Checks if the spoken text matches the expected letter
  static bool isCorrectPronunciation(String expectedLetter, String spokenText) {
    if (spokenText.isEmpty) return false;
    
    // Clean the spoken text
    String cleanSpoken = _cleanText(spokenText);
    String cleanExpected = _cleanText(expectedLetter);
    
    // Direct match (if user says the letter itself)
    if (cleanSpoken == cleanExpected) {
      return true;
    }
    
    // Check if the spoken text matches any of the letter's names
    List<String>? possibleNames = _letterToSpokenNames[expectedLetter];
    if (possibleNames == null) return false;
    
    for (String name in possibleNames) {
      if (cleanSpoken == _cleanText(name)) {
        return true;
      }
      
      // Partial match (in case of recognition issues)
      if (_fuzzyMatch(cleanSpoken, _cleanText(name))) {
        return true;
      }
    }
    
    return false;
  }

  /// Normalizes spoken text back to the letter character
  /// Returns the letter character if the spoken text matches any pronunciation
  /// Returns null if no match is found
  static String? normalizeSpokenTextToLetter(String spokenText) {
    if (spokenText.isEmpty) return null;
    
    String cleanSpoken = _cleanText(spokenText);
    
    // Check each letter and its possible pronunciations
    for (String letter in _letterToSpokenNames.keys) {
      // Direct match (if user says the letter itself)
      if (cleanSpoken == _cleanText(letter)) {
        return letter;
      }
      
      // Check if the spoken text matches any of the letter's names
      List<String> possibleNames = _letterToSpokenNames[letter]!;
      for (String name in possibleNames) {
        if (cleanSpoken == _cleanText(name)) {
          return letter;
        }
        
        // Partial match (in case of recognition issues)
        if (_fuzzyMatch(cleanSpoken, _cleanText(name))) {
          return letter;
        }
      }
    }
    
    return null; // No match found
  }

  /// Cleans text by removing diacritics and normalizing
  static String _cleanText(String text) {
    return text
        .trim()
        .toLowerCase()
        // Remove common diacritics
        .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '')
        // Normalize some common variations
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }

  /// Performs fuzzy matching for slight variations
  static bool _fuzzyMatch(String spoken, String expected) {
    // If the strings are very similar (allowing for 1-2 character differences)
    if (spoken.length == expected.length) {
      int differences = 0;
      for (int i = 0; i < spoken.length; i++) {
        if (spoken[i] != expected[i]) {
          differences++;
        }
      }
      return differences <= 1; // Allow 1 character difference
    }
    
    // Check if one is contained in the other (for partial recognition)
    if (spoken.length >= 2 && expected.length >= 2) {
      return spoken.contains(expected) || expected.contains(spoken);
    }
    
    return false;
  }

  /// Gets the primary name for a letter (for display purposes)
  static String getLetterName(String letter) {
    List<String>? names = _letterToSpokenNames[letter];
    return names?.first ?? letter;
  }

  /// Gets all possible names for a letter
  static List<String> getAllPossibleNames(String letter) {
    return _letterToSpokenNames[letter] ?? [letter];
  }

  /// Validates if a letter exists in our mapping
  static bool isValidLetter(String letter) {
    return _letterToSpokenNames.containsKey(letter);
  }
}