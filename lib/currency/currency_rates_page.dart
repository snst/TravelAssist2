import 'package:flutter/material.dart';

class CurrencyRatesPage extends StatelessWidget {
  const CurrencyRatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currencies!')),
      body: const Center(child: Text('Currencies Page!')),
    );
  }
}