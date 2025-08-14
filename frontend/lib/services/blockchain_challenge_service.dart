import 'dart:convert';
import 'package:solana/solana.dart';
import '../config/constants.dart';
import '../models/challenge.dart';

class BlockchainChallengeService {
  late RpcClient _client;
  Ed25519HDKeyPair? _keypair;
  late String _programId;
  bool _isInitialized = false;

  BlockchainChallengeService() {
    _client = RpcClient(RPC_ENDPOINT);
    _programId = PROGRAM_ID;
    _initializeKeypair();
  }

  // Initialize keypair asynchronously
  Future<void> _initializeKeypair() async {
    try {
      _keypair = await Ed25519HDKeyPair.random();
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize keypair: $e');
      _isInitialized = false;
    }
  }

  // Wait for initialization to complete
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeKeypair();
    }
  }

  // Initialize with existing keypair
  Future<void> initializeWithKeypair(String privateKey) async {
    try {
      final bytes = base64Decode(privateKey);
      _keypair = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: bytes);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize keypair: $e');
    }
  }

  // Get current public key
  Ed25519HDKeyPair? get keypair => _keypair;
  String get publicKey {
    if (_keypair == null) {
      return 'Initializing...';
    }
    return _keypair!.publicKey.toBase58();
  }

  // Check if service is ready
  bool get isReady => _isInitialized && _keypair != null;

  // Create a new Lichess challenge on the blockchain
  Future<String> createLichessChallenge({
    required double wagerAmount,
    required String lichessGameId,
    required Map<String, dynamic> timeControl,
  }) async {
    try {
      // Convert SOL to lamports
      final lamports = (wagerAmount * 1000000000).toInt(); // 1 SOL = 1,000,000,000 lamports

      // For now, we'll create a mock transaction since the full implementation
      // requires proper instruction building which is complex
      // In a real implementation, you would:
      // 1. Create the instruction data according to the IDL
      // 2. Build the transaction with proper accounts
      // 3. Sign and send the transaction
      
      // Simulate blockchain transaction delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate mock transaction signature for now
      final random = DateTime.now().millisecondsSinceEpoch;
      final signature = 'mock_tx_${random}_${_keypair!.publicKey.toBase58().substring(0, 8)}';
      
      return signature;
    } catch (e) {
      throw Exception('Failed to create challenge: $e');
    }
  }

  // Accept a Lichess challenge
  Future<String> acceptLichessChallenge({
    required String challengeCreator,
    required String challengeId,
  }) async {
    try {
      // Implementation for accepting challenge
      // This would follow the same pattern as createChallenge
      throw UnimplementedError('Accept challenge not yet implemented');
    } catch (e) {
      throw Exception('Failed to accept challenge: $e');
    }
  }

  // Complete a Lichess challenge
  Future<String> completeLichessChallenge({
    required String challengeId,
    required String winner,
    required Map<String, dynamic> lichessResult,
  }) async {
    try {
      // Implementation for completing challenge
      throw UnimplementedError('Complete challenge not yet implemented');
    } catch (e) {
      throw Exception('Failed to complete challenge: $e');
    }
  }

  // Cancel a Lichess challenge
  Future<String> cancelLichessChallenge({
    required String challengeId,
  }) async {
    try {
      // Implementation for canceling challenge
      throw UnimplementedError('Cancel challenge not yet implemented');
    } catch (e) {
      throw Exception('Failed to cancel challenge: $e');
    }
  }

  // Get challenge details from blockchain
  Future<Map<String, dynamic>> getChallengeDetails(String challengeId) async {
    try {
      // Implementation for fetching challenge details
      throw UnimplementedError('Get challenge details not yet implemented');
    } catch (e) {
      throw Exception('Failed to get challenge details: $e');
    }
  }

  // Get recent blockhash for transaction
  Future<String> _getRecentBlockhash() async {
    try {
      final response = await _client.getLatestBlockhash();
      return response.value.blockhash;
    } catch (e) {
      throw Exception('Failed to get recent blockhash: $e');
    }
  }

  // Get account balance
  Future<double> getBalance() async {
    try {
      final response = await _client.getBalance(_keypair!.publicKey.toBase58());
      return response.value / 1000000000; // Convert lamports to SOL
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  // Generate new keypair
  Future<void> generateNewKeypair() async {
    _keypair = await Ed25519HDKeyPair.random();
  }

  // Export private key
  Future<String> exportPrivateKey() async {
    // Note: This is a simplified export - in production you'd want proper key management
    // We need to extract the private key from the keypair
    final keypairData = await _keypair!.extract();
    return base64Encode(keypairData.bytes);
  }

  // Convert local challenge to blockchain format
  Map<String, dynamic> convertChallengeToBlockchain(Challenge challenge) {
    return {
      'creator': challenge.creator,
      'wagerAmount': challenge.wagerAmount,
      'lichessGameId': challenge.lichessGameId,
      'timeControl': {
        'initialTime': challenge.timeControl['initialTime'] ?? 600,
        'increment': challenge.timeControl['increment'] ?? 0,
        'variant': challenge.timeControl['variant'] ?? 'standard',
      },
      'isActive': challenge.isActive ? 1 : 0,
      'challenger': challenge.challenger ?? '',
      'isComplete': challenge.isCompleted ? 1 : 0,
      'createdAt': challenge.createdAt.millisecondsSinceEpoch ~/ 1000,
      'winner': challenge.winner ?? '',
      'creatorClaimed': false,
      'challengerClaimed': false,
    };
  }

  // Convert blockchain challenge to local format
  Challenge convertBlockchainToChallenge(Map<String, dynamic> blockchainChallenge) {
    return Challenge(
      id: blockchainChallenge['id'] ?? '',
      creator: blockchainChallenge['creator'] ?? '',
      challenger: blockchainChallenge['challenger'] ?? '',
      wagerAmount: (blockchainChallenge['wagerAmount'] ?? 0).toDouble(),
      lichessGameId: blockchainChallenge['lichessGameId'] ?? '',
      timeControl: Map<String, dynamic>.from(blockchainChallenge['timeControl'] ?? {}),
      status: blockchainChallenge['isComplete'] == 1 ? 'completed' : 
              blockchainChallenge['challenger'] != null ? 'active' : 'pending',
      winner: blockchainChallenge['winner'] ?? '',
      lichessResult: blockchainChallenge['lichessResult'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (blockchainChallenge['createdAt'] ?? 0) * 1000,
      ),
    );
  }
}
