import 'package:flutter/material.dart';

class HPage extends StatelessWidget {
  const HPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('H Page'),
      ),
      body: const Center(
        child: Text('Welcome to H Page!'),
      ),
    );
  }
}