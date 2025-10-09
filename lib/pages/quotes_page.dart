import 'package:flutter/material.dart';

class QuotesPage extends StatelessWidget {
  final String shipmentId;

  const QuotesPage({
    super.key,
    required this.shipmentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotes'),
      ),
      body: Center(
        child: Text('Quotes for shipment: $shipmentId'),
      ),
    );
  }
}
