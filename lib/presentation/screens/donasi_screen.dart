// lib/presentation/screens/donasi_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DonasiScreen extends StatelessWidget {
  const DonasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donasi'),
        actions: [
          IconButton(
            onPressed: () => Get.offAllNamed('/'), // Kembali ke Home
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volunteer_activism, color: primaryColor, size: 72),
              const SizedBox(height: 24),
              Text(
                'Fitur Donasi Segera Hadir',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Untuk saat ini, donasi dapat disalurkan langsung melalui '
                'pengurus Masjid Sabilillah.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
