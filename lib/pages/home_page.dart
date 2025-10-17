import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bockaire/widgets/modal/modal_utils.dart';
import 'package:bockaire/pages/new_shipment_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openNewShipmentModal(BuildContext context) {
    ModalUtils.showSinglePageModal(
      context: context,
      title: 'New Shipment',
      builder: (modalContext) => const NewShipmentContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bockaire'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Recent Shipments',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No shipments yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first shipment to get started',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewShipmentModal(context),
        icon: const Icon(Icons.add),
        label: const Text('New Shipment'),
      ),
    );
  }
}
