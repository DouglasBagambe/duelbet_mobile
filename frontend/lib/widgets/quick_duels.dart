import 'package:flutter/material.dart';

class QuickDuels extends StatelessWidget {
  const QuickDuels({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Duels',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Placeholder
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey[700],
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: const ListTile(
                    leading: Icon(Icons.sports_esports, color: Colors.blue),
                    title: Text(
                      'Liverpool vs Man United',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Soccer',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
