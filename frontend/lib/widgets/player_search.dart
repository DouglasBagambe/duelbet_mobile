import 'package:flutter/material.dart';

class PlayerSearch extends StatefulWidget {
  final Function(String) onSelect;
  const PlayerSearch({super.key, required this.onSelect});

  @override
  State<PlayerSearch> createState() => _PlayerSearchState();
}

class _PlayerSearchState extends State<PlayerSearch> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Search for a player',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              widget.onSelect(_controller.text);
            },
          ),
        ],
      ),
    );
  }
}
