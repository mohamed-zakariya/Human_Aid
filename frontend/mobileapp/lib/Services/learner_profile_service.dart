import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/generated/l10n.dart';
import '../../models/learner.dart';
import '../../graphql/graphql_client.dart';
import '../graphql/queries/learner_profile_query.dart';

class LearnerProfileService {
  static Future<Learner?> fetchLearnerProfile(String learnerId) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.query(
        QueryOptions(
          document: gql(getLearnerProfileQuery),
          variables: {'userId': learnerId},
          errorPolicy: ErrorPolicy.all,
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      final handledResult = await GraphQLService.handleAuthErrors(
        result: result,
        role: 'user',
        retryRequest: () async {
          final newClient = await GraphQLService.getClient();
          return await newClient.query(
            QueryOptions(
              document: gql(getLearnerProfileQuery),
              variables: {'userId': learnerId},
              errorPolicy: ErrorPolicy.all,
              fetchPolicy: FetchPolicy.networkOnly,
            ),
          );
        },
      );

      if (handledResult != null && 
          !handledResult.hasException && 
          handledResult.data != null) {
        final fetchedData = handledResult.data!['learnerProfile'];
        if (fetchedData != null) {
          return Learner.fromJson(fetchedData);
        }
      } else if (handledResult?.hasException == true) {
        throw Exception(handledResult!.exception.toString());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch learner profile: $e');
    }
  }

  /// Get achievement level based on total time spent (in minutes)
  static Map<String, dynamic> getAchievementLevel(BuildContext context, int? totalMinutes) {
    final localizations = S.of(context);
    
    if (totalMinutes == null || totalMinutes == 0) {
      return {
        'title': localizations.explorer,
        'color': 0xFF10B981,
        'icon': '🌱',
      };
    }

    if (totalMinutes < 60) { // Less than 1 hour
      return {
        'title': localizations.risingStar,
        'color': 0xFF3B82F6,
        'icon': '⭐',
      };
    } else if (totalMinutes < 300) { // Less than 5 hours
      return {
        'title': localizations.brightMind,
        'color': 0xFF8B5CF6,
        'icon': '💡',
      };
    } else if (totalMinutes < 600) { // Less than 10 hours
      return {
        'title': localizations.knowledgeSeeker,
        'color': 0xFFF59E0B,
        'icon': '🔍',
      };
    } else if (totalMinutes < 1200) { // Less than 20 hours
      return {
        'title': localizations.wisdomBuilder,
        'color': 0xFFEF4444,
        'icon': '🏗️',
      };
    } else if (totalMinutes < 2400) { // Less than 40 hours
      return {
        'title': localizations.masterLearner,
        'color': 0xFF06B6D4,
        'icon': '🎓',
      };
    } else {
      return {
        'title': localizations.learningChampion,
        'color': 0xFFDC2626,
        'icon': '🏆',
      };
    }
  }

  /// Get flag emoji based on nationality
  static String getFlagEmoji(String? nationality) {
    if (nationality == null) return '🌍';
    
    final flagMap = {
      'afghanistan': '🇦🇫',
      'albania': '🇦🇱',
      'algeria': '🇩🇿',
      'united states': '🇺🇸',
      'andorra': '🇦🇩',
      'angola': '🇦🇴',
      'argentina': '🇦🇷',
      'armenia': '🇦🇲',
      'australia': '🇦🇺',
      'austria': '🇦🇹',
      'azerbaijan': '🇦🇿',
      'bahrain': '🇧🇭',
      'bangladesh': '🇧🇩',
      'barbados': '🇧🇧',
      'belarus': '🇧🇾',
      'belgium': '🇧🇪',
      'belize': '🇧🇿',
      'benin': '🇧🇯',
      'bhutan': '🇧🇹',
      'bolivia': '🇧🇴',
      'bosnia and herzegovina': '🇧🇦',
      'botswana': '🇧🇼',
      'brazil': '🇧🇷',
      'united kingdom': '🇬🇧',
      'brunei': '🇧🇳',
      'bulgaria': '🇧🇬',
      'burkina faso': '🇧🇫',
      'myanmar': '🇲🇲',
      'burundi': '🇧🇮',
      'cambodia': '🇰🇭',
      'cameroon': '🇨🇲',
      'canada': '🇨🇦',
      'cape verde': '🇨🇻',
      'central african republic': '🇨🇫',
      'chad': '🇹🇩',
      'chile': '🇨🇱',
      'china': '🇨🇳',
      'colombia': '🇨🇴',
      'comoros': '🇰🇲',
      'republic of the congo': '🇨🇬',
      'costa rica': '🇨🇷',
      'croatia': '🇭🇷',
      'cuba': '🇨🇺',
      'cyprus': '🇨🇾',
      'czech republic': '🇨🇿',
      'denmark': '🇩🇰',
      'djibouti': '🇩🇯',
      'dominican republic': '🇩🇴',
      'netherlands': '🇳🇱',
      'ecuador': '🇪🇨',
      'egypt': '🇪🇬',
      'united arab emirates': '🇦🇪',
      'england': '🏴',
      'eritrea': '🇪🇷',
      'estonia': '🇪🇪',
      'ethiopia': '🇪🇹',
      'fiji': '🇫🇯',
      'philippines': '🇵🇭',
      'finland': '🇫🇮',
      'france': '🇫🇷',
      'gabon': '🇬🇦',
      'gambia': '🇬🇲',
      'georgia': '🇬🇪',
      'germany': '🇩🇪',
      'ghana': '🇬🇭',
      'greece': '🇬🇷',
      'grenada': '🇬🇩',
      'guatemala': '🇬🇹',
      'guinea': '🇬🇳',
      'guyana': '🇬🇾',
      'haiti': '🇭🇹',
      'honduras': '🇭🇳',
      'hungary': '🇭🇺',
      'iceland': '🇮🇸',
      'india': '🇮🇳',
      'indonesia': '🇮🇩',
      'iran': '🇮🇷',
      'iraq': '🇮🇶',
      'ireland': '🇮🇪',
      'israel': '🇮🇱',
      'italy': '🇮🇹',
      'ivory coast': '🇨🇮',
      'jamaica': '🇯🇲',
      'japan': '🇯🇵',
      'jordan': '🇯🇴',
      'kazakhstan': '🇰🇿',
      'kenya': '🇰🇪',
      'kuwait': '🇰🇼',
      'kyrgyzstan': '🇰🇬',
      'laos': '🇱🇦',
      'latvia': '🇱🇻',
      'lebanon': '🇱🇧',
      'liberia': '🇱🇷',
      'libya': '🇱🇾',
      'lithuania': '🇱🇹',
      'luxembourg': '🇱🇺',
      'north macedonia': '🇲🇰',
      'madagascar': '🇲🇬',
      'malawi': '🇲🇼',
      'malaysia': '🇲🇾',
      'maldives': '🇲🇻',
      'mali': '🇲🇱',
      'malta': '🇲🇹',
      'mauritania': '🇲🇷',
      'mauritius': '🇲🇺',
      'mexico': '🇲🇽',
      'moldova': '🇲🇩',
      'mongolia': '🇲🇳',
      'montenegro': '🇲🇪',
      'morocco': '🇲🇦',
      'mozambique': '🇲🇿',
      'namibia': '🇳🇦',
      'nepal': '🇳🇵',
      'new zealand': '🇳🇿',
      'nicaragua': '🇳🇮',
      'niger': '🇳🇪',
      'nigeria': '🇳🇬',
      'norway': '🇳🇴',
      'oman': '🇴🇲',
      'pakistan': '🇵🇰',
      'palestine': '🇵🇸',
      'panama': '🇵🇦',
      'paraguay': '🇵🇾',
      'peru': '🇵🇪',
      'poland': '🇵🇱',
      'portugal': '🇵🇹',
      'qatar': '🇶🇦',
      'romania': '🇷🇴',
      'russia': '🇷🇺',
      'rwanda': '🇷🇼',
      'saudi arabia': '🇸🇦',
      'scotland': '🏴',
      'senegal': '🇸🇳',
      'serbia': '🇷🇸',
      'singapore': '🇸🇬',
      'slovakia': '🇸🇰',
      'slovenia': '🇸🇮',
      'somalia': '🇸🇴',
      'south africa': '🇿🇦',
      'south korea': '🇰🇷',
      'spain': '🇪🇸',
      'sri lanka': '🇱🇰',
      'sudan': '🇸🇩',
      'sweden': '🇸🇪',
      'switzerland': '🇨🇭',
      'syria': '🇸🇾',
      'taiwan': '🇹🇼',
      'tajikistan': '🇹🇯',
      'tanzania': '🇹🇿',
      'thailand': '🇹🇭',
      'togo': '🇹🇬',
      'trinidad and tobago': '🇹🇹',
      'tunisia': '🇹🇳',
      'turkey': '🇹🇷',
      'turkmenistan': '🇹🇲',
      'uganda': '🇺🇬',
      'ukraine': '🇺🇦',
      'uruguay': '🇺🇾',
      'uzbekistan': '🇺🇿',
      'venezuela': '🇻🇪',
      'vietnam': '🇻🇳',
      'wales': '🏴',
      'yemen': '🇾🇪',
      'zambia': '🇿🇲',
      'zimbabwe': '🇿🇼'
    };
    
    return flagMap[nationality.toLowerCase()] ?? '🌍';
  }
}