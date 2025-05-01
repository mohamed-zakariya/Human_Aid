import 'package:flutter/material.dart';

/// Universal letter model
///
/// – keeps the _original_ public fields (`id`, `letter`, `color`, `group`)
///   so code written elsewhere still works.
/// – adds two handy getters (`glyph` and `colour`) that the new Level-2
///   screen uses.  
///   They are just aliases, so nothing else breaks.
class Letter {
  final String id;
  final String letter;
  final String? color; // hex string like #FFCC00 or null
  final String group;

  Letter({
    required this.id,
    required this.letter,
    required this.group,
    this.color,
  });

  /// Convenience: Arabic glyph
  String get glyph => letter;

  /// Convenience: parsed Color object, or pastel fallback
  Color get colour {
    if (color != null &&
        color!.startsWith('#') &&
        (color!.length == 7 || color!.length == 9)) {
      return Color(int.parse(color!.substring(1), radix: 16) + 0xFF000000);
    }
    // deterministic pastel fallback so every run gets the same colour
    return Colors.primaries[id.hashCode.abs() % Colors.primaries.length];
  }

  factory Letter.fromJson(Map<String, dynamic> json) => Letter(
        id     : json['_id']    ?? '',
        letter : json['letter'] ?? '',
        color  : json['color'],
        group  : json['group']  ?? '',
      );

  @override
  String toString() => 'Letter($letter, group:$group)';
}
