import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import '../lib/lichess_backend_service.dart';

void main(List<String> args) async {
  // Create router
  final router = Router();

  // Add CORS headers
  final handler = const Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router);

  // Health check endpoint
  router.get('/health', (Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
        'service': 'DuelBet Mobile Backend',
        'version': '1.0.0',
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // Lichess user info endpoint
  router.get('/api/lichess/user/<username>', (Request request, String username) async {
    try {
      final userInfo = await LichessBackendService.getUserInfo(username);
      return Response.ok(
        jsonEncode(userInfo),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.notFound(
        jsonEncode({
          'error': e.toString(),
          'username': username,
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  // Lichess user games endpoint
  router.get('/api/lichess/games/<username>', (Request request, String username) async {
    try {
      final queryParams = request.url.queryParameters;
      final max = int.tryParse(queryParams['max'] ?? '10') ?? 10;
      final rated = queryParams['rated'] != 'false';
      
      final games = await LichessBackendService.getUserGames(
        username,
        max: max,
        rated: rated,
      );
      
      return Response.ok(
        jsonEncode({'games': games}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'error': e.toString(),
          'username': username,
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  // Lichess user performance endpoint
  router.get('/api/lichess/perf/<username>/<perf>', (Request request, String username, String perf) async {
    try {
      final perfData = await LichessBackendService.getUserPerf(username, perf);
      return Response.ok(
        jsonEncode(perfData),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'error': e.toString(),
          'username': username,
          'perf': perf,
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  // Lichess search users endpoint
  router.get('/api/lichess/search', (Request request) async {
    try {
      final query = request.url.queryParameters['q'];
      if (query == null || query.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Query parameter "q" is required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final users = await LichessBackendService.searchUsers(query);
      return Response.ok(
        jsonEncode(users),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  // Cache management endpoints
  router.get('/api/cache/stats', (Request request) {
    final stats = LichessBackendService.getCacheStats();
    return Response.ok(
      jsonEncode(stats),
      headers: {'content-type': 'application/json'},
    );
  });

  router.get('/api/cache/rate-limit', (Request request) {
    final status = LichessBackendService.getRateLimitStatus();
    return Response.ok(
      jsonEncode(status),
      headers: {'content-type': 'application/json'},
    );
  });

  router.delete('/api/cache/user/<username>', (Request request, String username) {
    LichessBackendService.clearUserCache(username);
    return Response.ok(
      jsonEncode({'message': 'Cache cleared for user: $username'}),
      headers: {'content-type': 'application/json'},
    );
  });

  router.delete('/api/cache/all', (Request request) {
    LichessBackendService.clearAllCache();
    return Response.ok(
      jsonEncode({'message': 'All cache cleared'}),
      headers: {'content-type': 'application/json'},
    );
  });

  // Start server
  final server = await io.serve(
    handler,
    InternetAddress.anyIPv4,
    3001,
  );

  print('🚀 DuelBet Mobile Backend Server running on http://localhost:${server.port}');
  print('📊 Health check: http://localhost:${server.port}/health');
  print('🔍 Lichess API proxy: http://localhost:${server.port}/api/lichess/');
  print('💾 Cache management: http://localhost:${server.port}/api/cache/');
} 