import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/lichess_service.dart';
import '../models/lichess_player.dart';
import '../services/challenge_service.dart';
import '../services/blockchain_challenge_service.dart';
import '../components/challenge_list.dart';
import '../services/theme_service.dart';
import '../components/menu_bar.dart';
import 'player_search_screen.dart';

class LichessScreen extends StatefulWidget {
  const LichessScreen({Key? key}) : super(key: key);

  @override
  State<LichessScreen> createState() => _LichessScreenState();
}

class _LichessScreenState extends State<LichessScreen>
    with TickerProviderStateMixin {
  LichessPlayer? _selectedPlayer;
  String _wagerAmount = '';
  Map<String, dynamic> _timeControl = {
    'initialTime': 600,
    'increment': 5,
    'variant': 'standard',
  };

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Text editing controllers
  late TextEditingController _wagerController;
  late TextEditingController _initialTimeController;
  late TextEditingController _incrementController;

  // Challenge service listener
  late Function() _challengeListener;

  // Blockchain service
  late BlockchainChallengeService _blockchainService;
  bool _isBlockchainReady = false;
  bool _isRefreshingBalance = false;

  @override
  void initState() {
    super.initState();

    // Initialize text controllers
    _wagerController = TextEditingController(text: _wagerAmount);
    _initialTimeController = TextEditingController(text: (_timeControl['initialTime'] / 60).toString());
    _incrementController = TextEditingController(text: _timeControl['increment'].toString());

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();

    // Initialize blockchain service
    _blockchainService = BlockchainChallengeService();

    // Wait for blockchain service to be ready
    _waitForBlockchainReady();

    // Check authentication status
    _checkAuthStatus();
  }

  // Wait for blockchain service to be ready
  Future<void> _waitForBlockchainReady() async {
    try {
      await _blockchainService.ensureInitialized();
      // Refresh balance when ready
      await _blockchainService.refreshBalance();
      setState(() {
        _isBlockchainReady = true;
      });
    } catch (e) {
      print('Failed to initialize blockchain service: $e');
      setState(() {
        _isBlockchainReady = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _wagerController.dispose();
    _initialTimeController.dispose();
    _incrementController.dispose();

    ChallengeService.removeListener(_challengeListener);

    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    // For now, we'll simulate authentication
    setState(() {
      _isAuthenticated = true; // Simulate authenticated
    });

    // Load sample challenges for demonstration
    ChallengeService.loadSampleChallenges();

    // Listen for challenge updates
    _challengeListener = () {
      if (mounted) {
        setState(() {
          // Refresh the UI when challenges update
        });
      }
    };
    ChallengeService.addListener(_challengeListener);
  }

  Future<void> _authenticateWithLichess() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate OAuth flow
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });

      _showSuccess('Successfully authenticated with Lichess!');
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication failed: $e';
        _isLoading = false;
      });
      _showError('Authentication failed');
    }
  }

  Future<void> _createChallenge() async {
    if (_selectedPlayer == null) {
      _showError('Please select an opponent');
      return;
    }

    if (_wagerAmount.isEmpty || double.tryParse(_wagerAmount) == null) {
      _showError('Please enter a valid wager amount');
      return;
    }

    if (!_isBlockchainReady) {
      _showError('Wallet is not ready yet. Please wait for initialization.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create challenge on blockchain
      final wagerAmount = double.parse(_wagerAmount);
      final lichessGameId = 'game_${DateTime.now().millisecondsSinceEpoch}';

      final transactionSignature = await _blockchainService.createLichessChallenge(
        wagerAmount: wagerAmount,
        lichessGameId: lichessGameId,
        timeControl: _timeControl,
      );

      // Create local challenge record
      final challenge = ChallengeService.createChallenge(
        creator: _blockchainService.publicKey,
        wagerAmount: wagerAmount,
        lichessGameId: lichessGameId,
        timeControl: _timeControl,
      );

      setState(() {
        _isLoading = false;
      });

      _showSuccess('Challenge created on blockchain! Transaction: ${transactionSignature.substring(0, 8)}...');

      // Reset form
      setState(() {
        _selectedPlayer = null;
        _wagerAmount = '';
        _wagerController.clear();
        _initialTimeController.text = '10';
        _incrementController.text = '5';
        _timeControl['initialTime'] = 600;
        _timeControl['increment'] = 5;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create challenge: $e';
        _isLoading = false;
      });
      _showError('Failed to create challenge: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Scaffold(
          backgroundColor: themeService.backgroundColor,
          body: Column(
            children: [
              // Menu Bar
              AppMenuBar(
                title: 'Lichess Challenges',
                showBackButton: true,
              ),
              // Main Content
              Expanded(
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Wallet Connection Section
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade900.withOpacity(0.3),
                                      Colors.red.shade900.withOpacity(0.3),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.orange.shade600.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.orange.shade600,
                                                  Colors.red.shade600,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.account_balance_wallet,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              'Solana Wallet',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: themeService.textColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          if (!_isAuthenticated)
                                            ElevatedButton(
                                              onPressed: _isLoading ? null : _authenticateWithLichess,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue.shade600,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: _isLoading
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Connect Lichess',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                            ),
                                          if (_isAuthenticated)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade600.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.green.shade600.withOpacity(0.5),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                'Connected',
                                                style: TextStyle(
                                                  color: Colors.green.shade400,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      if (!_isBlockchainReady)
                                        // Loading state
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: themeService.cardColor.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.orange.shade600.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Initializing wallet...',
                                                style: TextStyle(
                                                  color: themeService.textColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        // Wallet Info
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: themeService.cardColor.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.orange.shade600.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Wallet Name
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.account_circle,
                                                    color: Colors.orange.shade600,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      _blockchainService.walletName,
                                                      style: TextStyle(
                                                        color: themeService.textColor,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              // Public Key
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Public Key:',
                                                    style: TextStyle(
                                                      color: themeService.secondaryTextColor,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          _blockchainService.publicKey,
                                                          style: TextStyle(
                                                            color: themeService.textColor,
                                                            fontSize: 12,
                                                            fontFamily: 'monospace',
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Clipboard.setData(ClipboardData(text: _blockchainService.publicKey));
                                                          _showSuccess('Public key copied to clipboard!');
                                                        },
                                                        icon: Icon(
                                                          Icons.copy,
                                                          color: Colors.orange.shade600,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              // Balance
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.account_balance_wallet,
                                                    color: Colors.orange.shade600,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Balance:',
                                                    style: TextStyle(
                                                      color: themeService.secondaryTextColor,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _blockchainService.balanceVisible
                                                        ? '${_blockchainService.cachedBalance.toStringAsFixed(4)} SOL'
                                                        : '••••••••',
                                                    style: TextStyle(
                                                      color: themeService.textColor,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      fontFamily: 'monospace',
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  IconButton(
                                                    onPressed: () async {
                                                      await _blockchainService.toggleBalanceVisibility();
                                                      setState(() {});
                                                    },
                                                    icon: Icon(
                                                      _blockchainService.balanceVisible
                                                          ? Icons.visibility_off
                                                          : Icons.visibility,
                                                      color: Colors.orange.shade600,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 16),
                                      // Wallet Actions
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                // await _blockchainService.generateNewKeypair();
                                                // setState(() {});
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange.shade600,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'New Wallet',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _isRefreshingBalance
                                                  ? null
                                                  : () async {
                                                      setState(() {
                                                        _isRefreshingBalance = true;
                                                      });

                                                      try {
                                                        await _blockchainService.refreshBalance();
                                                        setState(() {});
                                                      } finally {
                                                        setState(() {
                                                          _isRefreshingBalance = false;
                                                        });
                                                      }
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red.shade600,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: _isRefreshingBalance
                                                  ? SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Refresh Balance',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              if (_isAuthenticated) ...[
                                // Player Search Section
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade900.withOpacity(0.3),
                                        Colors.purple.shade900.withOpacity(0.3),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: Colors.blue.shade600.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.shade600,
                                                    Colors.purple.shade600,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.search,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                'Find Opponent',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: themeService.textColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        // Player Search Button
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => PlayerSearchScreen(
                                                    onPlayerSelected: (player) {
                                                      setState(() {
                                                        _selectedPlayer = player;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              );

                                              if (result != null) {
                                                setState(() {
                                                  _selectedPlayer = result;
                                                });
                                                _showSuccess('Selected: ${result.username}');
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue.shade600,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              'Search for Player',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Selected Player Display
                                        if (_selectedPlayer != null) ...[
                                          const SizedBox(height: 20),
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade900.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.green.shade600.withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.shade600,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        _selectedPlayer!.username,
                                                        style: TextStyle(
                                                          color: themeService.textColor,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                      if (_selectedPlayer!.hasTitle)
                                                        Text(
                                                          _selectedPlayer!.title!,
                                                          style: TextStyle(
                                                            color: Colors.yellow.shade400,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _selectedPlayer = null;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.close,
                                                    color: themeService.textColor,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Challenge Configuration
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade900.withOpacity(0.3),
                                        Colors.orange.shade900.withOpacity(0.3),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: Colors.purple.shade600.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.purple.shade600,
                                                    Colors.orange.shade600,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.settings,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                'Challenge Settings',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: themeService.textColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        // Wager Amount
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Wager Amount (SOL)',
                                              style: TextStyle(
                                                color: themeService.secondaryTextColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: themeService.surfaceColor.withOpacity(0.8),
                                                border: Border.all(
                                                  color: themeService.secondaryTextColor.withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: TextField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    _wagerAmount = value;
                                                  });
                                                },
                                                controller: _wagerController,
                                                style: TextStyle(
                                                  color: themeService.textColor,
                                                  fontSize: 16,
                                                ),
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: '0.0',
                                                  hintStyle: TextStyle(
                                                    color: themeService.secondaryTextColor.withOpacity(0.5),
                                                  ),
                                                  border: InputBorder.none,
                                                  contentPadding: const EdgeInsets.all(16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        // Time Control
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Time Control',
                                              style: TextStyle(
                                                color: themeService.secondaryTextColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: themeService.surfaceColor.withOpacity(0.8),
                                                      border: Border.all(
                                                        color: themeService.secondaryTextColor.withOpacity(0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: TextField(
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _timeControl['initialTime'] = (int.tryParse(value) ?? 10) * 60;
                                                        });
                                                      },
                                                      controller: _initialTimeController,
                                                      style: TextStyle(
                                                        color: themeService.textColor,
                                                        fontSize: 16,
                                                      ),
                                                      keyboardType: TextInputType.number,
                                                      decoration: InputDecoration(
                                                        hintText: '10',
                                                        hintStyle: TextStyle(
                                                          color: themeService.secondaryTextColor.withOpacity(0.5),
                                                        ),
                                                        border: InputBorder.none,
                                                        contentPadding: const EdgeInsets.all(16),
                                                        suffixText: 'min',
                                                        suffixStyle: TextStyle(
                                                          color: themeService.secondaryTextColor.withOpacity(0.5),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: themeService.surfaceColor.withOpacity(0.8),
                                                      border: Border.all(
                                                        color: themeService.secondaryTextColor.withOpacity(0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: TextField(
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _timeControl['increment'] = int.tryParse(value) ?? 5;
                                                        });
                                                      },
                                                      controller: _incrementController,
                                                      style: TextStyle(
                                                        color: themeService.textColor,
                                                        fontSize: 16,
                                                      ),
                                                      keyboardType: TextInputType.number,
                                                      decoration: InputDecoration(
                                                        hintText: '5',
                                                        hintStyle: TextStyle(
                                                          color: themeService.secondaryTextColor.withOpacity(0.5),
                                                        ),
                                                        border: InputBorder.none,
                                                        contentPadding: const EdgeInsets.all(16),
                                                        suffixText: 'sec',
                                                        suffixStyle: TextStyle(
                                                          color: themeService.secondaryTextColor.withOpacity(0.5),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Create Challenge Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: (_selectedPlayer != null && _wagerAmount.isNotEmpty && !_isLoading)
                                        ? _createChallenge
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Creating Challenge...',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Text(
                                            'Create Challenge',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                                // Error Message
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade900.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.red.shade600.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red.shade400,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: TextStyle(
                                              color: Colors.red.shade300,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 32),
                                // Active Challenges Section
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.shade900.withOpacity(0.3),
                                        Colors.red.shade900.withOpacity(0.3),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: Colors.orange.shade600.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.orange.shade600,
                                                    Colors.red.shade600,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.list_alt,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                'Active Challenges',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: themeService.textColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        // Challenge List
                                        ChallengeList(
                                          challenges: ChallengeService.challenges,
                                          onChallengeUpdate: () {
                                            setState(() {
                                              // Refresh the UI when challenges update
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else
                                // Not Authenticated State
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue.shade600,
                                              Colors.purple.shade600,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(60),
                                        ),
                                        child: const Icon(
                                          Icons.psychology,
                                          color: Colors.white,
                                          size: 60,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      Text(
                                        'Connect to Lichess',
                                        style: TextStyle(
                                          color: themeService.textColor,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Connect your Lichess account to start creating chess challenges and wagering on games.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: themeService.secondaryTextColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _isLoading ? null : _authenticateWithLichess,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue.shade600,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 20),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isLoading
                                              ? const Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Connecting...',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : const Text(
                                                  'Connect with Lichess',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}