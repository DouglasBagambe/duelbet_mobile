import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class LichessBackendService {
  static const String _baseUrl = 'https://lichess.org/api';
  static const String _userAgent = 'DuelBet-Mobile/1.0';
  
  // Rate limiting
  static const int _maxRequestsPerMinute = 60;
  static final Map<String, List<DateTime>> _requestHistory = {};
  
  // Cache for user data
  static final Map<String, Map<String, dynamic>> _userCache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// Check if we can make a request (rate limiting)
  static bool _canMakeRequest(String endpoint) {
    final now = DateTime.now();
    final key = endpoint;
    
    if (!_requestHistory.containsKey(key)) {
      _requestHistory[key] = [];
    }
    
    final requests = _requestHistory[key]!;
    
    // Remove requests older than 1 minute
    requests.removeWhere((time) => now.difference(time).inMinutes >= 1);
    
    if (requests.length >= _maxRequestsPerMinute) {
      return false;
    }
    
    requests.add(now);
    return true;
  }

  /// Get cached user data if available and not expired
  static Map<String, dynamic>? _getCachedUser(String username) {
    final cacheKey = 'user_$username';
    final timestamp = _cacheTimestamps[cacheKey];
    
    if (timestamp != null && 
        DateTime.now().difference(timestamp) < _cacheExpiry &&
        _userCache.containsKey(cacheKey)) {
      return _userCache[cacheKey];
    }
    
    return null;
  }

  /// Cache user data
  static void _cacheUser(String username, Map<String, dynamic> data) {
    final cacheKey = 'user_$username';
    _userCache[cacheKey] = data;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }

  /// Make a rate-limited HTTP request
  static Future<http.Response> _makeRequest(String endpoint) async {
    if (!_canMakeRequest(endpoint)) {
      throw Exception('Rate limit exceeded. Please try again in a minute.');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': _userAgent,
        },
      ).timeout(const Duration(seconds: 10));

      return response;
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } on FormatException {
      throw Exception('Invalid response format from Lichess.');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  /// Get user information with caching
  static Future<Map<String, dynamic>> getUserInfo(String username) async {
    // Check cache first
    final cached = _getCachedUser(username);
    if (cached != null) {
      return cached;
    }

    final response = await _makeRequest('/user/$username');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _cacheUser(username, data);
      return data;
    } else if (response.statusCode == 404) {
      throw Exception('User not found: $username');
    } else {
      throw Exception('Failed to get user info: ${response.statusCode}');
    }
  }

  /// Get user's game history
  static Future<List<Map<String, dynamic>>> getUserGames(
    String username, {
    int max = 10,
    bool rated = true,
    String? variant,
    String? color,
    String? analysed,
  }) async {
    final queryParams = <String, String>{
      'max': max.toString(),
      'rated': rated.toString(),
    };
    
    if (variant != null) queryParams['variant'] = variant;
    if (color != null) queryParams['color'] = color;
    if (analysed != null) queryParams['analysed'] = analysed;

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _makeRequest('/games/user/$username?$queryString');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['games'] ?? []);
    } else {
      throw Exception('Failed to get user games: ${response.statusCode}');
    }
  }

  /// Get user's rating history
  static Future<List<Map<String, dynamic>>> getUserRatingHistory(String username) async {
    final response = await _makeRequest('/user/$username/rating-history');
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to get rating history: ${response.statusCode}');
    }
  }

  /// Get user's performance statistics for a specific game type
  static Future<Map<String, dynamic>> getUserPerf(
    String username, 
    String perf
  ) async {
    final response = await _makeRequest('/user/$username/perf/$perf');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get performance stats: ${response.statusCode}');
    }
  }

  /// Search for users (autocomplete)
  static Future<List<Map<String, dynamic>>> searchUsers(
    String query, {
    int max = 10,
    bool friend = false,
  }) async {
    final response = await _makeRequest(
      '/user/autocomplete?friend=$friend&term=${Uri.encodeComponent(query)}'
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to search users: ${response.statusCode}');
    }
  }

  /// Get user's online status
  static Future<bool> isUserOnline(String username) async {
    try {
      final userInfo = await getUserInfo(username);
      return userInfo['online'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Get user's playing status
  static Future<bool> isUserPlaying(String username) async {
    try {
      final userInfo = await getUserInfo(username);
      return userInfo['playing'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Get user's title
  static Future<String?> getUserTitle(String username) async {
    try {
      final userInfo = await getUserInfo(username);
      return userInfo['title'];
    } catch (e) {
      return null;
    }
  }

  /// Get user's current rating for a specific game type
  static Future<int?> getUserRating(String username, String perf) async {
    try {
      final perfData = await getUserPerf(username, perf);
      return perfData['perf']?['glicko']?['rating']?.toInt();
    } catch (e) {
      return null;
    }
  }

  /// Get user's game count for a specific game type
  static Future<int?> getUserGameCount(String username, String perf) async {
    try {
      final perfData = await getUserPerf(username, perf);
      return perfData['perf']?['games']?.toInt();
    } catch (e) {
      return null;
    }
  }

  /// Get user's win rate for a specific game type
  static Future<double?> getUserWinRate(String username, String perf) async {
    try {
      final perfData = await getUserPerf(username, perf);
      final games = perfData['perf']?['games']?.toInt() ?? 0;
      final wins = perfData['perf']?['wins']?.toInt() ?? 0;
      
      if (games > 0) {
        return (wins / games) * 100;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get user's recent activity
  static Future<List<Map<String, dynamic>>> getUserActivity(String username) async {
    final response = await _makeRequest('/user/$username/activity');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to get user activity: ${response.statusCode}');
    }
  }

  /// Get user's tournament history
  static Future<List<Map<String, dynamic>>> getUserTournaments(String username) async {
    final response = await _makeRequest('/user/$username/tournament/created');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to get user tournaments: ${response.statusCode}');
    }
  }

  /// Get user's puzzle statistics
  static Future<Map<String, dynamic>?> getUserPuzzleStats(String username) async {
    final response = await _makeRequest('/user/$username/puzzle-activity');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get puzzle stats: ${response.statusCode}');
    }
  }

  /// Get user's team information
  static Future<List<Map<String, dynamic>>> getUserTeams(String username) async {
    final response = await _makeRequest('/user/$username/team');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to get user teams: ${response.statusCode}');
    }
  }

  /// Get user's follow list
  static Future<List<Map<String, dynamic>>> getUserFollowing(String username) async {
    final response = await _makeRequest('/user/$username/following');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to get user following: ${response.statusCode}');
    }
  }

  /// Get user's followers
  static Future<List<Map<String, dynamic>>> getUserFollowers(String username) async {
    final response = await _makeRequest('/user/$username/followers');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to get user followers: ${response.statusCode}');
    }
  }

  /// Clear cache for a specific user
  static void clearUserCache(String username) {
    final cacheKey = 'user_$username';
    _userCache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
  }

  /// Clear all cache
  static void clearAllCache() {
    _userCache.clear();
    _cacheTimestamps.clear();
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cachedUsers': _userCache.length,
      'cacheSize': _cacheTimestamps.length,
      'requestHistory': _requestHistory.map((key, value) => MapEntry(key, value.length)),
    };
  }

  /// Get rate limit status
  static Map<String, dynamic> getRateLimitStatus() {
    final now = DateTime.now();
    final status = <String, dynamic>{};
    
    _requestHistory.forEach((endpoint, requests) {
      final recentRequests = requests.where(
        (time) => now.difference(time).inMinutes < 1
      ).length;
      
      status[endpoint] = {
        'requestsLastMinute': recentRequests,
        'canMakeRequest': recentRequests < _maxRequestsPerMinute,
        'remainingRequests': _maxRequestsPerMinute - recentRequests,
      };
    });
    
    return status;
  }
} 