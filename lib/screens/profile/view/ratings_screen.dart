import 'package:flutter/material.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ratings')),
      body: const Center(child: Text('Ratings Screen ')),
    );
  }
} 