import 'package:flutter/material.dart';

class Challenge {
  final String id;
  final String creator;
  final String? challenger;
  final double wagerAmount;
  final String lichessGameId;
  final Map<String, dynamic> timeControl;
  final String status;
  final String? winner;
  final Map<String, dynamic>? lichessResult;
  final DateTime createdAt;

  Challenge({
    required this.id,
    required this.creator,
    this.challenger,
    required this.wagerAmount,
    required this.lichessGameId,
    required this.timeControl,
    required this.status,
    this.winner,
    this.lichessResult,
    required this.createdAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? '',
      creator: json['creator'] ?? '',
      challenger: json['challenger'],
      wagerAmount: (json['wagerAmount'] ?? 0).toDouble(),
      lichessGameId: json['lichessGameId'] ?? '',
      timeControl: Map<String, dynamic>.from(json['timeControl'] ?? {}),
      status: json['status'] ?? 'pending',
      winner: json['winner'],
      lichessResult: json['lichessResult'] != null 
          ? Map<String, dynamic>.from(json['lichessResult'])
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator': creator,
      'challenger': challenger,
      'wagerAmount': wagerAmount,
      'lichessGameId': lichessGameId,
      'timeControl': timeControl,
      'status': status,
      'winner': winner,
      'lichessResult': lichessResult,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Get formatted time control string
  String get timeControlDisplay {
    final initialMinutes = (timeControl['initialTime'] ?? 600) / 60;
    final increment = timeControl['increment'] ?? 0;
    return '${initialMinutes.toInt()}min + ${increment}s';
  }

  // Get chess variant display name
  String get variantDisplayName {
    final variant = timeControl['variant'] ?? 'standard';
    final displayNames = {
      'standard': 'Standard',
      'chess960': 'Chess960',
      'crazyhouse': 'Crazyhouse',
      'antichess': 'Antichess',
      'atomic': 'Atomic',
      'horde': 'Horde',
      'kingOfTheHill': 'King of the Hill',
      'racingKings': 'Racing Kings',
      'threeCheck': 'Three Check',
    };
    return displayNames[variant] ?? variant;
  }

  // Get status display text
  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'active':
        return 'Active';
      case 'accepted':
        return 'Accepted';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Get status color
  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'active':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Check if challenge is active
  bool get isActive => status == 'active' || status == 'accepted';

  // Check if challenge is completed
  bool get isCompleted => status == 'completed';

  // Check if challenge is pending
  bool get isPending => status == 'pending';

  // Get formatted wager amount
  String get wagerAmountDisplay => '${wagerAmount.toStringAsFixed(2)} SOL';

  // Get time since creation
  String get timeSinceCreation {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Copy with method for immutability
  Challenge copyWith({
    String? id,
    String? creator,
    String? challenger,
    double? wagerAmount,
    String? lichessGameId,
    Map<String, dynamic>? timeControl,
    String? status,
    String? winner,
    Map<String, dynamic>? lichessResult,
    DateTime? createdAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      creator: creator ?? this.creator,
      challenger: challenger ?? this.challenger,
      wagerAmount: wagerAmount ?? this.wagerAmount,
      lichessGameId: lichessGameId ?? this.lichessGameId,
      timeControl: timeControl ?? this.timeControl,
      status: status ?? this.status,
      winner: winner ?? this.winner,
      lichessResult: lichessResult ?? this.lichessResult,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Challenge(id: $id, creator: $creator, wagerAmount: $wagerAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Challenge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 