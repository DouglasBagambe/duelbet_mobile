import 'package:flutter/material.dart';

class CreateWagerDialog extends StatefulWidget {
  const CreateWagerDialog({super.key});

  @override
  State<CreateWagerDialog> createState() => _CreateWagerDialogState();
}

class _CreateWagerDialogState extends State<CreateWagerDialog> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  String _optionA = '';
  String _optionB = '';
  String _amount = '';
  String _eventId = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: const Text('Create a New Duel', style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Option A',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter option A';
                  }
                  return null;
                },
                onSaved: (value) {
                  _optionA = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Option B',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter option B';
                  }
                  return null;
                },
                onSaved: (value) {
                  _optionB = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount (SOL)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Event ID',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  _eventId = value!;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Create Wager'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              // TODO: Implement create wager logic
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
