import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barkod Hub'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ürün sorgulamak için barkod okutabilir veya manuel barkod girebilirsin.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Barkod Tara'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.keyboard),
              label: const Text('Manuel Barkod Gir'),
            ),
          ],
        ),
      ),
    );
  }
}