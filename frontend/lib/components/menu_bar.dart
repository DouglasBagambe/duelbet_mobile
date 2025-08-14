import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../screens/settings_screen.dart';

class AppMenuBar extends StatelessWidget {
  final String? title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const AppMenuBar({
    Key? key,
    this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: themeService.backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: themeService.textColor.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Back Button
                if (showBackButton)
                  IconButton(
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: themeService.textColor,
                      size: 24,
                    ),
                  ),
                
                // Title
                if (title != null) ...[
                  if (showBackButton) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: themeService.textColor,
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),
                
                // Actions
                if (actions != null) ...[
                  ...actions!,
                  const SizedBox(width: 8),
                ],
                
                // Settings Button
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.settings,
                    color: themeService.textColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Floating Action Button Menu Bar (for screens without app bar)
class FloatingAppMenuBar extends StatelessWidget {
  final VoidCallback? onSettingsPressed;

  const FloatingAppMenuBar({
    Key? key,
    this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: themeService.surfaceColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: themeService.textColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Settings Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (onSettingsPressed != null) {
                        onSettingsPressed!();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.settings,
                        color: themeService.textColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Bottom App Bar (for screens with bottom navigation)
class BottomAppMenuBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomAppMenuBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Container(
          decoration: BoxDecoration(
            color: themeService.surfaceColor,
            border: Border(
              top: BorderSide(
                color: themeService.textColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMenuItem(
                    context: context,
                    themeService: themeService,
                    icon: Icons.home,
                    label: 'Home',
                    index: 0,
                    isSelected: currentIndex == 0,
                  ),
                  _buildMenuItem(
                    context: context,
                    themeService: themeService,
                    icon: Icons.psychology,
                    label: 'Lichess',
                    index: 1,
                    isSelected: currentIndex == 1,
                  ),
                  _buildMenuItem(
                    context: context,
                    themeService: themeService,
                    icon: Icons.sports_mma,
                    label: '1v1',
                    index: 2,
                    isSelected: currentIndex == 2,
                  ),
                  _buildMenuItem(
                    context: context,
                    themeService: themeService,
                    icon: Icons.settings,
                    label: 'Settings',
                    index: 3,
                    isSelected: currentIndex == 3,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required ThemeService themeService,
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? themeService.textColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? themeService.textColor
                  : themeService.secondaryTextColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                    ? themeService.textColor
                    : themeService.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 