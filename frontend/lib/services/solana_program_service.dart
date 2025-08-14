import 'dart:convert';
import 'dart:math';
import 'package:solana/solana.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class SolanaProgramService {
  late RpcClient _client;
  Ed25519HDKeyPair? _keypair;
  late String _programId;
  bool _isInitialized = false;
  bool _balanceVisible = false;
  String _walletName = '';
  double _cachedBalance = 0.0;
  
  // SharedPreferences keys
  static const String _walletPrivateKeyKey = 'solana_program_wallet_private_key';
  static const String _walletNameKey = 'solana_program_wallet_name';
  static const String _balanceVisibleKey = 'solana_program_balance_visible';

  SolanaProgramService() {
    _client = RpcClient(RPC_ENDPOINT);
    _programId = PROGRAM_ID;
    _loadPersistedWallet();
  }

  // Load persisted wallet from storage
  Future<void> _loadPersistedWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final privateKeyString = prefs.getString(_walletPrivateKeyKey);
      _walletName = prefs.getString(_walletNameKey) ?? _generateWalletName();
      _balanceVisible = prefs.getBool(_balanceVisibleKey) ?? false;
      
      if (privateKeyString != null) {
        await initializeWithKeypair(privateKeyString);
      } else {
        await _initializeKeypair();
      }
    } catch (e) {
      print('Failed to load persisted wallet: $e');
      await _initializeKeypair();
    }
  }

  // Generate a random wallet name
  String _generateWalletName() {
    final adjectives = ['Swift', 'Bold', 'Clever', 'Bright', 'Quick', 'Smart', 'Sharp', 'Wise'];
    final nouns = ['Fox', 'Eagle', 'Lion', 'Wolf', 'Hawk', 'Bear', 'Tiger', 'Dragon'];
    final random = Random();
    return '${adjectives[random.nextInt(adjectives.length)]} ${nouns[random.nextInt(nouns.length)]}';
  }

  // Save wallet to persistent storage
  Future<void> _saveWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_keypair != null) {
        final privateKey = await exportPrivateKey();
        await prefs.setString(_walletPrivateKeyKey, privateKey);
        await prefs.setString(_walletNameKey, _walletName);
        await prefs.setBool(_balanceVisibleKey, _balanceVisible);
      }
    } catch (e) {
      print('Failed to save wallet: $e');
    }
  }

  // Initialize keypair asynchronously
  Future<void> _initializeKeypair() async {
    try {
      _keypair = await Ed25519HDKeyPair.random();
      _walletName = _generateWalletName();
      _isInitialized = true;
      await _saveWallet();
    } catch (e) {
      print('Failed to initialize keypair: $e');
      _isInitialized = false;
    }
  }

  // Wait for initialization to complete
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _loadPersistedWallet();
    }
  }

  // Initialize with existing keypair
  Future<void> initializeWithKeypair(String privateKey) async {
    try {
      final bytes = base64Decode(privateKey);
      _keypair = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: bytes);
      _isInitialized = true;
      await _saveWallet();
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

  // Get wallet name
  String get walletName => _walletName;

  // Get balance visibility state
  bool get balanceVisible => _balanceVisible;

  // Get cached balance
  double get cachedBalance => _cachedBalance;

  // Check if service is ready
  bool get isReady => _isInitialized && _keypair != null;

  // Toggle balance visibility
  Future<void> toggleBalanceVisibility() async {
    _balanceVisible = !_balanceVisible;
    await _saveWallet();
  }

  // Update wallet name
  Future<void> updateWalletName(String newName) async {
    _walletName = newName;
    await _saveWallet();
  }

  // Create a challenge on the blockchain
  Future<String> createChallenge({
    required double wagerAmount,
    required String gameId,
    required Map<String, dynamic> gameConfig,
  }) async {
    try {
      if (_keypair == null) {
        throw Exception('No keypair available');
      }
      
      final lamports = (wagerAmount * 1000000000).toInt();
      
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

  // Accept a challenge
  Future<String> acceptChallenge({
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

  // Complete a challenge
  Future<String> completeChallenge({
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

  // Cancel a challenge
  Future<String> cancelChallenge({
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
      if (_keypair == null) {
        throw Exception('No keypair available');
      }
      final response = await _client.getBalance(_keypair!.publicKey.toBase58());
      _cachedBalance = response.value / 1000000000; // Convert lamports to SOL
      await _saveWallet(); // Save the cached balance
      return _cachedBalance;
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  // Refresh cached balance
  Future<void> refreshBalance() async {
    try {
      await getBalance();
    } catch (e) {
      print('Failed to refresh balance: $e');
    }
  }

  // Generate new keypair
  Future<void> generateNewKeypair() async {
    try {
      // Clear old wallet data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_walletPrivateKeyKey);
      await prefs.remove(_walletNameKey);
      await prefs.remove(_balanceVisibleKey);
      
      // Generate new wallet
      _keypair = await Ed25519HDKeyPair.random();
      _walletName = _generateWalletName();
      _balanceVisible = false;
      _cachedBalance = 0.0;
      _isInitialized = true;
      
      // Save new wallet
      await _saveWallet();
    } catch (e) {
      throw Exception('Failed to generate new keypair: $e');
    }
  }

  // Export private key
  Future<String> exportPrivateKey() async {
    // We need to extract the private key from the keypair
    if (_keypair == null) {
      throw Exception('No keypair available');
    }
    final keypairData = await _keypair!.extract();
    return base64Encode(keypairData.bytes);
  }
}
