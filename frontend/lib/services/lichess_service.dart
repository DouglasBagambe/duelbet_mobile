import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class LichessService {
  static const String _baseUrl = 'https://lichess.org/api';
  
  // Simple rate limiting
  static DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 1000); // 1 second between requests
  
  // Get user information
  static Future<Map<String, dynamic>?> getUserInfo(String username) async {
    // Check rate limiting
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final waitTime = _minRequestInterval - timeSinceLastRequest;
        await Future.delayed(waitTime);
      }
    }
    
    try {
      _lastRequestTime = DateTime.now();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$username'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'DuelBet-Mobile/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('User not found: $username');
      } else {
        throw Exception('Failed to get user info: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      throw Exception('Error fetching user info: $e');
    }
  }

  // Get user's game history
  static Future<List<Map<String, dynamic>>> getUserGames(String username, {int max = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/games/user/$username?max=$max'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['games'] ?? []);
      } else {
        throw Exception('Failed to get user games: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user games: $e');
    }
  }

  // Get user's rating history
  static Future<List<Map<String, dynamic>>> getUserRatingHistory(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$username/rating-history'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to get rating history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching rating history: $e');
    }
  }

  // Get user's performance statistics
  static Future<Map<String, dynamic>?> getUserPerf(String username, String perf) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$username/perf/$perf'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get performance stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching performance stats: $e');
    }
  }

  // Search for users
  static Future<List<Map<String, dynamic>>> searchUsers(String query, {int max = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/autocomplete?friend=$query'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to search users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }

  // Get challenge details (if you have a challenge ID)
  static Future<Map<String, dynamic>?> getChallengeDetails(String challengeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/challenge/$challengeId'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get challenge details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching challenge details: $e');
    }
  }

  // Get user's online status
  static Future<bool> isUserOnline(String username) async {
    try {
      final userInfo = await getUserInfo(username);
      return userInfo?['online'] == true;
    } catch (e) {
      return false;
    }
  }

  // Get user's playing status
  static Future<bool> isUserPlaying(String username) async {
    try {
      final userInfo = await getUserInfo(username);
      return userInfo?['playing'] == true;
    } catch (e) {
      return false;
    }
  }

  // Get user's title
  static Future<String?> getUserTitle(String username) async {
    try {
      final userInfo = await getUserInfo(username);
      return userInfo?['title'];
    } catch (e) {
      return null;
    }
  }

  // Get user's current rating for a specific game type
  static Future<int?> getUserRating(String username, String perf) async {
    try {
      final perfData = await getUserPerf(username, perf);
      return perfData?['perf']?['glicko']?['rating']?.toInt();
    } catch (e) {
      return null;
    }
  }

  // Get user's provisional rating status
  static Future<bool> isUserProvisional(String username, String perf) async {
    try {
      final perfData = await getUserPerf(username, perf);
      return perfData?['perf']?['glicko']?['provisional'] == true;
    } catch (e) {
      return false;
    }
  }

  // Get user's game count for a specific game type
  static Future<int?> getUserGameCount(String username, String perf) async {
    try {
      final perfData = await getUserPerf(username, perf);
      return perfData?['perf']?['games']?.toInt();
    } catch (e) {
      return null;
    }
  }

  // Get user's win rate for a specific game type
  static Future<double?> getUserWinRate(String username, String perf) async {
    try {
      final perfData = await getUserPerf(username, perf);
      final games = perfData?['perf']?['games']?.toInt() ?? 0;
      final wins = perfData?['perf']?['wins']?.toInt() ?? 0;
      
      if (games > 0) {
        return (wins / games) * 100;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get user's recent activity
  static Future<List<Map<String, dynamic>>> getUserActivity(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$username/activity'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to get user activity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user activity: $e');
    }
  }

  // Get user's tournament history
  static Future<List<Map<String, dynamic>>> getUserTournaments(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$username/tournament/created'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to get user tournaments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user tournaments: $e');
    }
  }

  // Get user's puzzle statistics
  static Future<Map<String, dynamic>?> getUserPuzzleStats(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$username/puzzle-activity'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get puzzle stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching puzzle stats: $e');
    }
  }

  // Get user's team information
  static Future<List<Map<String, dynamic>>> getUserTeams(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$username/team'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to get user teams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user teams: $e');
    }
  }

  // Get user's follow list
  static Future<List<Map<String, dynamic>>> getUserFollowing(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$username/following'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to get user following: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user following: $e');
    }
  }

  // Get user's followers
  static Future<List<Map<String, dynamic>>> getUserFollowers(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$username/followers'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to get user followers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user followers: $e');
    }
  }
} 