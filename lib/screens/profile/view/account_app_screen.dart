import 'package:flutter/material.dart';

class AccountAppScreen extends StatelessWidget {
  const AccountAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account & App')),
      body: const Center(child: Text('Account & App Screen ')),
    );
  }
} 