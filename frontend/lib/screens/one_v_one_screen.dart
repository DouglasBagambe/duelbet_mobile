import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../components/menu_bar.dart';
import '../widgets/quick_duels.dart';
import '../widgets/create_wager_dialog.dart';

class OneVOneScreen extends StatelessWidget {
  const OneVOneScreen({super.key});

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
                title: '1v1 Duel',
                showBackButton: true,
              ),
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const CreateWagerDialog();
                            },
                          );
                        },
                        child: const Text('Create a New Duel'),
                      ),
                      const SizedBox(height: 20),
                      const Expanded(
                        child: QuickDuels(),
                      ),
                    ],
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
