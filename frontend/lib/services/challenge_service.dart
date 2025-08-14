import '../models/challenge.dart';

class ChallengeService {
  static final List<Challenge> _challenges = [];
  static final List<Function()> _listeners = [];

  // Get all challenges
  static List<Challenge> get challenges => List.unmodifiable(_challenges);

  // Add a challenge
  static void addChallenge(Challenge challenge) {
    _challenges.add(challenge);
    _notifyListeners();
  }

  // Update a challenge
  static void updateChallenge(String id, Challenge updatedChallenge) {
    final index = _challenges.indexWhere((c) => c.id == id);
    if (index != -1) {
      _challenges[index] = updatedChallenge;
      _notifyListeners();
    }
  }

  // Remove a challenge
  static void removeChallenge(String id) {
    _challenges.removeWhere((c) => c.id == id);
    _notifyListeners();
  }

  // Accept a challenge
  static void acceptChallenge(String id, String challenger) {
    final index = _challenges.indexWhere((c) => c.id == id);
    if (index != -1) {
      final challenge = _challenges[index];
      final updatedChallenge = challenge.copyWith(
        challenger: challenger,
        status: 'accepted',
      );
      _challenges[index] = updatedChallenge;
      _notifyListeners();
    }
  }

  // Complete a challenge
  static void completeChallenge(String id, String winner) {
    final index = _challenges.indexWhere((c) => c.id == id);
    if (index != -1) {
      final challenge = _challenges[index];
      final updatedChallenge = challenge.copyWith(
        status: 'completed',
        winner: winner,
      );
      _challenges[index] = updatedChallenge;
      _notifyListeners();
    }
  }

  // Get challenges by status
  static List<Challenge> getChallengesByStatus(String status) {
    return _challenges.where((c) => c.status == status).toList();
  }

  // Get challenges by creator
  static List<Challenge> getChallengesByCreator(String creator) {
    return _challenges.where((c) => c.creator == creator).toList();
  }

  // Get challenges by challenger
  static List<Challenge> getChallengesByChallenger(String challenger) {
    return _challenges.where((c) => c.challenger == challenger).toList();
  }

  // Get active challenges
  static List<Challenge> get activeChallenges {
    return _challenges.where((c) => c.isActive).toList();
  }

  // Get pending challenges
  static List<Challenge> get pendingChallenges {
    return _challenges.where((c) => c.isPending).toList();
  }

  // Get completed challenges
  static List<Challenge> get completedChallenges {
    return _challenges.where((c) => c.isCompleted).toList();
  }

  // Add a listener for changes
  static void addListener(Function() listener) {
    _listeners.add(listener);
  }

  // Remove a listener
  static void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // Clear all challenges (for testing)
  static void clearAll() {
    _challenges.clear();
    _notifyListeners();
  }

  // Load sample challenges for demonstration
  static void loadSampleChallenges() {
    if (_challenges.isNotEmpty) return; // Don't reload if already have challenges
    
    final sampleChallenges = [
      // Challenge(
      //   id: '1',
      //   creator: 'DrNykterstein',
      //   wagerAmount: 0.5,
      //   lichessGameId: 'abc123',
      //   timeControl: {
      //     'initialTime': 600,
      //     'increment': 5,
      //     'variant': 'standard',
      //   },
      //   status: 'pending',
      //   createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      // ),
      // Challenge(
      //   id: '2',
      //   creator: 'Hikaru',
      //   challenger: 'Magnus',
      //   wagerAmount: 1.0,
      //   lichessGameId: 'def456',
      //   timeControl: {
      //     'initialTime': 300,
      //     'increment': 3,
      //     'variant': 'chess960',
      //   },
      //   status: 'active',
      //   createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      // ),
      // Challenge(
      //   id: '3',
      //   creator: 'Magnus',
      //   challenger: 'Hikaru',
      //   wagerAmount: 2.0,
      //   lichessGameId: 'ghi789',
      //   timeControl: {
      //     'initialTime': 900,
      //     'increment': 10,
      //     'variant': 'atomic',
      //   },
      //   status: 'completed',
      //   winner: 'Magnus',
      //   createdAt: DateTime.now().subtract(const Duration(days: 1)),
      // ),
    ];

    for (final challenge in sampleChallenges) {
      _challenges.add(challenge);
    }
    
    _notifyListeners();
  }

  // Create a new challenge
  static Challenge createChallenge({
    required String creator,
    required double wagerAmount,
    required String lichessGameId,
    required Map<String, dynamic> timeControl,
  }) {
    final challenge = Challenge(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      creator: creator,
      wagerAmount: wagerAmount,
      lichessGameId: lichessGameId,
      timeControl: timeControl,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    addChallenge(challenge);
    return challenge;
  }

  // Get challenge statistics
  static Map<String, dynamic> getStatistics() {
    final total = _challenges.length;
    final pending = pendingChallenges.length;
    final active = activeChallenges.length;
    final completed = completedChallenges.length;
    final totalWagered = _challenges.fold<double>(
      0.0,
      (sum, challenge) => sum + challenge.wagerAmount,
    );

    return {
      'total': total,
      'pending': pending,
      'active': active,
      'completed': completed,
      'totalWagered': totalWagered,
    };
  }

  // Search challenges
  static List<Challenge> searchChallenges(String query) {
    if (query.isEmpty) return _challenges;
    
    final lowercaseQuery = query.toLowerCase();
    return _challenges.where((challenge) {
      return challenge.creator.toLowerCase().contains(lowercaseQuery) ||
             challenge.lichessGameId.toLowerCase().contains(lowercaseQuery) ||
             challenge.variantDisplayName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get challenges by time range
  static List<Challenge> getChallengesByTimeRange(DateTime start, DateTime end) {
    return _challenges.where((challenge) {
      return challenge.createdAt.isAfter(start) && 
             challenge.createdAt.isBefore(end);
    }).toList();
  }

  // Get recent challenges
  static List<Challenge> getRecentChallenges(int count) {
    final sorted = List<Challenge>.from(_challenges);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(count).toList();
  }
} 