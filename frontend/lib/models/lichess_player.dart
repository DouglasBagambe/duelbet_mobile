class LichessPlayer {
  final String id;
  final String username;
  final String? title;
  final bool? online;
  final bool? playing;
  final bool? patron;
  final int? nbGames;
  final int? nbRatedGames;
  final int? nbWins;
  final int? nbLosses;
  final int? nbDraws;
  final int? nbPlaying;
  final int? nbFinish;
  final int? nbBookmark;
  final bool? hasPlayed;
  final bool? following;
  final bool? followingIn;
  final bool? blocking;
  final bool? followsYou;

  LichessPlayer({
    required this.id,
    required this.username,
    this.title,
    this.online,
    this.playing,
    this.patron,
    this.nbGames,
    this.nbRatedGames,
    this.nbWins,
    this.nbLosses,
    this.nbDraws,
    this.nbPlaying,
    this.nbFinish,
    this.nbBookmark,
    this.hasPlayed,
    this.following,
    this.followingIn,
    this.blocking,
    this.followsYou,
  });

  factory LichessPlayer.fromJson(Map<String, dynamic> json) {
    return LichessPlayer(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      title: json['title'],
      online: json['online'],
      playing: json['playing'],
      patron: json['patron'],
      nbGames: json['nbGames'],
      nbRatedGames: json['nbRatedGames'],
      nbWins: json['nbWins'],
      nbLosses: json['nbLosses'],
      nbDraws: json['nbDraws'],
      nbPlaying: json['nbPlaying'],
      nbFinish: json['nbFinish'],
      nbBookmark: json['nbBookmark'],
      hasPlayed: json['hasPlayed'],
      following: json['following'],
      followingIn: json['followingIn'],
      blocking: json['blocking'],
      followsYou: json['followsYou'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'title': title,
      'online': online,
      'playing': playing,
      'patron': patron,
      'nbGames': nbGames,
      'nbRatedGames': nbRatedGames,
      'nbWins': nbWins,
      'nbLosses': nbLosses,
      'nbDraws': nbDraws,
      'nbPlaying': nbPlaying,
      'nbFinish': nbFinish,
      'nbBookmark': nbBookmark,
      'hasPlayed': hasPlayed,
      'following': following,
      'followingIn': followingIn,
      'blocking': blocking,
      'followsYou': followsYou,
    };
  }

  // Calculate win rate
  double? get winRate {
    if (nbGames == null || nbGames == 0) return null;
    return (nbWins ?? 0) / nbGames! * 100;
  }

  // Calculate loss rate
  double? get lossRate {
    if (nbGames == null || nbGames == 0) return null;
    return (nbLosses ?? 0) / nbGames! * 100;
  }

  // Calculate draw rate
  double? get drawRate {
    if (nbGames == null || nbGames == 0) return null;
    return (nbDraws ?? 0) / nbGames! * 100;
  }

  // Get total games
  int get totalGames => nbGames ?? 0;

  // Get rated games
  int get ratedGames => nbRatedGames ?? 0;

  // Check if player is currently online
  bool get isOnline => online ?? false;

  // Check if player is currently playing
  bool get isPlaying => playing ?? false;

  // Check if player has a title
  bool get hasTitle => title != null && title!.isNotEmpty;

  // Get display name (username with title if available)
  String get displayName {
    if (hasTitle) {
      return '$title $username';
    }
    return username;
  }

  // Get status text
  String get statusText {
    if (isPlaying) return 'Playing';
    if (isOnline) return 'Online';
    return 'Offline';
  }

  // Get status color (for UI)
  String get statusColor {
    if (isPlaying) return 'playing';
    if (isOnline) return 'online';
    return 'offline';
  }

  // Copy with method for immutability
  LichessPlayer copyWith({
    String? id,
    String? username,
    String? title,
    bool? online,
    bool? playing,
    bool? patron,
    int? nbGames,
    int? nbRatedGames,
    int? nbWins,
    int? nbLosses,
    int? nbDraws,
    int? nbPlaying,
    int? nbFinish,
    int? nbBookmark,
    bool? hasPlayed,
    bool? following,
    bool? followingIn,
    bool? blocking,
    bool? followsYou,
  }) {
    return LichessPlayer(
      id: id ?? this.id,
      username: username ?? this.username,
      title: title ?? this.title,
      online: online ?? this.online,
      playing: playing ?? this.playing,
      patron: patron ?? this.patron,
      nbGames: nbGames ?? this.nbGames,
      nbRatedGames: nbRatedGames ?? this.nbRatedGames,
      nbWins: nbWins ?? this.nbWins,
      nbLosses: nbLosses ?? this.nbLosses,
      nbDraws: nbDraws ?? this.nbDraws,
      nbPlaying: nbPlaying ?? this.nbPlaying,
      nbFinish: nbFinish ?? this.nbFinish,
      nbBookmark: nbBookmark ?? this.nbBookmark,
      hasPlayed: hasPlayed ?? this.hasPlayed,
      following: following ?? this.following,
      followingIn: followingIn ?? this.followingIn,
      blocking: blocking ?? this.blocking,
      followsYou: followsYou ?? this.followsYou,
    );
  }

  @override
  String toString() {
    return 'LichessPlayer(id: $id, username: $username, title: $title, online: $online, playing: $playing)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LichessPlayer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 