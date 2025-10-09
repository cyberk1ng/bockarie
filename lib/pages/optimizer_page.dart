import 'package:flutter/material.dart';

class OptimizerPage extends StatelessWidget {
  final String shipmentId;

  const OptimizerPage({
    super.key,
    required this.shipmentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimizer'),
      ),
      body: Center(
        child: Text('Optimizer for shipment: $shipmentId'),
      ),
    );
  }
}
