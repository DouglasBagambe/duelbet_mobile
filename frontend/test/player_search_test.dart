import 'package:flutter_test/flutter_test.dart';
import 'package:duelbet_mobile/services/lichess_service.dart';
import 'package:duelbet_mobile/models/lichess_player.dart';

void main() {
  group('LichessService Tests', () {
    test('should get user info for valid username', () async {
      // Test with a known Lichess user
      final userData = await LichessService.getUserInfo('DrNykterstein');
      
      expect(userData, isNotNull);
      expect(userData!['username'], equals('DrNykterstein'));
      expect(userData['id'], isNotNull);
    });

    test('should handle invalid username gracefully', () async {
      // Test with a non-existent username
      try {
        await LichessService.getUserInfo('ThisUserDoesNotExist12345');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e.toString(), contains('User not found'));
      }
    });

    test('should create LichessPlayer from JSON', () {
      final jsonData = {
        'id': 'test123',
        'username': 'testuser',
        'title': 'GM',
        'online': true,
        'playing': false,
        'nbGames': 1000,
        'nbWins': 600,
        'nbLosses': 300,
        'nbDraws': 100,
      };

      final player = LichessPlayer.fromJson(jsonData);

      expect(player.id, equals('test123'));
      expect(player.username, equals('testuser'));
      expect(player.title, equals('GM'));
      expect(player.isOnline, isTrue);
      expect(player.isPlaying, isFalse);
      expect(player.totalGames, equals(1000));
      expect(player.winRate, equals(60.0));
      expect(player.lossRate, equals(30.0));
      expect(player.drawRate, equals(10.0));
    });

    test('should handle missing optional fields', () {
      final jsonData = {
        'id': 'test123',
        'username': 'testuser',
      };

      final player = LichessPlayer.fromJson(jsonData);

      expect(player.id, equals('test123'));
      expect(player.username, equals('testuser'));
      expect(player.title, isNull);
      expect(player.isOnline, isFalse);
      expect(player.isPlaying, isFalse);
      expect(player.totalGames, equals(0));
      expect(player.winRate, isNull);
    });

    test('should calculate win rate correctly', () {
      final player = LichessPlayer(
        id: 'test123',
        username: 'testuser',
        nbGames: 100,
        nbWins: 70,
        nbLosses: 20,
        nbDraws: 10,
      );

      expect(player.winRate, equals(70.0));
      expect(player.lossRate, equals(20.0));
      expect(player.drawRate, equals(10.0));
    });

    test('should handle zero games', () {
      final player = LichessPlayer(
        id: 'test123',
        username: 'testuser',
        nbGames: 0,
        nbWins: 0,
        nbLosses: 0,
        nbDraws: 0,
      );

      expect(player.winRate, isNull);
      expect(player.lossRate, isNull);
      expect(player.drawRate, isNull);
    });

    test('should get display name with title', () {
      final playerWithTitle = LichessPlayer(
        id: 'test123',
        username: 'testuser',
        title: 'GM',
      );

      final playerWithoutTitle = LichessPlayer(
        id: 'test456',
        username: 'testuser2',
      );

      expect(playerWithTitle.displayName, equals('GM testuser'));
      expect(playerWithoutTitle.displayName, equals('testuser2'));
    });

    test('should get correct status text', () {
      final onlinePlayer = LichessPlayer(
        id: 'test123',
        username: 'testuser',
        online: true,
        playing: false,
      );

      final playingPlayer = LichessPlayer(
        id: 'test456',
        username: 'testuser2',
        online: true,
        playing: true,
      );

      final offlinePlayer = LichessPlayer(
        id: 'test789',
        username: 'testuser3',
        online: false,
        playing: false,
      );

      expect(onlinePlayer.statusText, equals('Online'));
      expect(playingPlayer.statusText, equals('Playing'));
      expect(offlinePlayer.statusText, equals('Offline'));
    });
  });
} 