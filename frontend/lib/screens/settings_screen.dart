import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Scaffold(
          backgroundColor: themeService.backgroundColor,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: themeService.textColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: themeService.textColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Theme Section
                      _buildSettingsSection(
                        context: context,
                        themeService: themeService,
                        title: 'Appearance',
                        icon: Icons.palette,
                        iconColor: Colors.purple,
                        children: [
                          _buildThemeToggle(context, themeService),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Account Section
                      _buildSettingsSection(
                        context: context,
                        themeService: themeService,
                        title: 'Account',
                        icon: Icons.person,
                        iconColor: Colors.blue,
                        children: [
                          _buildSettingsTile(
                            context: context,
                            themeService: themeService,
                            title: 'Profile',
                            subtitle: 'Manage your profile information',
                            icon: Icons.person_outline,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // TODO: Navigate to profile
                            },
                          ),
                          _buildSettingsTile(
                            context: context,
                            themeService: themeService,
                            title: 'Wallet',
                            subtitle: 'Connect and manage your wallet',
                            icon: Icons.account_balance_wallet_outlined,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // TODO: Navigate to wallet
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Notifications Section
                      _buildSettingsSection(
                        context: context,
                        themeService: themeService,
                        title: 'Notifications',
                        icon: Icons.notifications,
                        iconColor: Colors.orange,
                        children: [
                          _buildSettingsTile(
                            context: context,
                            themeService: themeService,
                            title: 'Push Notifications',
                            subtitle: 'Receive notifications for challenges',
                            icon: Icons.notifications_outlined,
                            trailing: Switch(
                              value: true, // TODO: Get from settings
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                // TODO: Update notification settings
                              },
                              activeColor: Colors.blue.shade600,
                            ),
                          ),
                          _buildSettingsTile(
                            context: context,
                            themeService: themeService,
                            title: 'Email Notifications',
                            subtitle: 'Receive email updates',
                            icon: Icons.email_outlined,
                            trailing: Switch(
                              value: false, // TODO: Get from settings
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                // TODO: Update email settings
                              },
                              activeColor: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Support Section
                      _buildSettingsSection(
                        context: context,
                        themeService: themeService,
                        title: 'Support',
                        icon: Icons.help,
                        iconColor: Colors.green,
                        children: [
                          _buildSettingsTile(
                            context: context,
                            themeService: themeService,
                            title: 'Help Center',
                            subtitle: 'Get help and find answers',
                            icon: Icons.help_outline,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // TODO: Open help center
                            },
                          ),
                          _buildSettingsTile(
                            context: context,
                            themeService: themeService,
                            title: 'Contact Support',
                            subtitle: 'Get in touch with our team',
                            icon: Icons.support_agent_outlined,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // TODO: Contact support
                            },
                          ),
                          _buildSettingsTile(
                            context: context,
                            themeService: themeService,
                            title: 'Privacy Policy',
                            subtitle: 'Read our privacy policy',
                            icon: Icons.privacy_tip_outlined,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // TODO: Show privacy policy
                            },
                          ),
                          _buildSettingsTile(
                            context: context,
                            themeService: themeService,
                            title: 'Terms of Service',
                            subtitle: 'Read our terms of service',
                            icon: Icons.description_outlined,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // TODO: Show terms of service
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // App Info Section
                      _buildSettingsSection(
                        context: context,
                        themeService: themeService,
                        title: 'App Info',
                        icon: Icons.info,
                        iconColor: Colors.grey,
                        children: [
                          _buildSettingsTile(
                            context: context,
                            themeService: themeService,
                            title: 'Version',
                            subtitle: '1.0.0',
                            icon: Icons.info_outline,
                            onTap: () {},
                          ),
                          _buildSettingsTile(
                            context: context,
                            themeService: themeService,
                            title: 'Build Number',
                            subtitle: '1',
                            icon: Icons.build_outlined,
                            onTap: () {},
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _showLogoutDialog(context, themeService);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required ThemeService themeService,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            iconColor.withOpacity(0.1),
            iconColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: themeService.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeService themeService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeService.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeService.textColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: themeService.isDarkMode ? Colors.purple : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeService.textColor,
                  ),
                ),
                Text(
                  themeService.isDarkMode 
                      ? 'Switch to light mode' 
                      : 'Switch to dark mode',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeService.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: themeService.isDarkMode,
            onChanged: (value) async {
              HapticFeedback.mediumImpact();
              await themeService.toggleTheme();
            },
            activeColor: Colors.purple.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required ThemeService themeService,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeService.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeService.textColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: themeService.textColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeService.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
                if (onTap != null && trailing == null)
                  Icon(
                    Icons.chevron_right,
                    color: themeService.secondaryTextColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ThemeService themeService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeService.surfaceColor,
          title: Text(
            'Logout',
            style: TextStyle(color: themeService.textColor),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: themeService.secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement logout
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Logged out successfully'),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
} 