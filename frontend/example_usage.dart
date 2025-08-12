import 'package:duelbet_mobile/services/lichess_service.dart';
import 'package:duelbet_mobile/models/lichess_player.dart';

/// Example usage of the DuelBet Mobile Player Search System
/// This demonstrates how to use the LichessService and LichessPlayer model
/// without needing the backend server running.

void main() async {
  print('🎯 DuelBet Mobile - Player Search Demo');
  print('=====================================\n');

  try {
    // Example 1: Search for a well-known Lichess player
    print('🔍 Searching for player: DrNykterstein');
    final userData = await LichessService.getUserInfo('DrNykterstein');
    
    if (userData != null) {
      final player = LichessPlayer.fromJson(userData);
      printPlayerInfo(player);
    }

    print('\n' + '=' * 50 + '\n');

    // Example 2: Search for another player
    print('🔍 Searching for player: Hikaru');
    final userData2 = await LichessService.getUserInfo('Hikaru');
    
    if (userData2 != null) {
      final player2 = LichessPlayer.fromJson(userData2);
      printPlayerInfo(player2);
    }

    print('\n' + '=' * 50 + '\n');

    // Example 3: Demonstrate error handling
    print('🔍 Searching for non-existent player: ThisUserDoesNotExist12345');
    try {
      await LichessService.getUserInfo('ThisUserDoesNotExist12345');
    } catch (e) {
      print('❌ Error: $e');
    }

    print('\n' + '=' * 50 + '\n');

    // Example 4: Show model functionality
    print('🧪 Testing LichessPlayer model functionality:');
    final testPlayer = LichessPlayer(
      id: 'test123',
      username: 'testuser',
      title: 'GM',
      online: true,
      playing: false,
      nbGames: 1000,
      nbWins: 700,
      nbLosses: 250,
      nbDraws: 50,
    );

    print('• Username: ${testPlayer.username}');
    print('• Display Name: ${testPlayer.displayName}');
    print('• Status: ${testPlayer.statusText}');
    print('• Total Games: ${testPlayer.totalGames}');
    print('• Win Rate: ${testPlayer.winRate?.toStringAsFixed(1)}%');
    print('• Loss Rate: ${testPlayer.lossRate?.toStringAsFixed(1)}%');
    print('• Draw Rate: ${testPlayer.drawRate?.toStringAsFixed(1)}%');

  } catch (e) {
    print('❌ Unexpected error: $e');
  }
}

void printPlayerInfo(LichessPlayer player) {
  print('✅ Player found!');
  print('• Username: ${player.username}');
  print('• Display Name: ${player.displayName}');
  print('• Status: ${player.statusText}');
  print('• Total Games: ${player.totalGames}');
  
  if (player.winRate != null) {
    print('• Win Rate: ${player.winRate!.toStringAsFixed(1)}%');
  }
  
  if (player.lossRate != null) {
    print('• Loss Rate: ${player.lossRate!.toStringAsFixed(1)}%');
  }
  
  if (player.drawRate != null) {
    print('• Draw Rate: ${player.drawRate!.toStringAsFixed(1)}%');
  }
  
  print('• Online: ${player.isOnline ? "Yes" : "No"}');
  print('• Playing: ${player.isPlaying ? "Yes" : "No"}');
}

/// To run this example:
/// 1. Make sure you're in the frontend directory
/// 2. Run: dart run example_usage.dart
/// 
/// Note: This requires an internet connection to fetch data from Lichess API
/// The service includes rate limiting (1 second between requests) to be respectful
/// to the Lichess API. 