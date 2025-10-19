import 'package:flutter/material.dart';
import 'package:bockaire/services/ai_provider_interfaces.dart';
import 'package:bockaire/widgets/image/image_analysis_modal.dart';

class ImageInputButton extends StatelessWidget {
  final Function(List<CartonData>) onCartonsDetected;

  const ImageInputButton({required this.onCartonsDetected, super.key});

  Future<void> _showImageModal(BuildContext context) async {
    final result = await showModalBottomSheet<List<CartonData>>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ImageAnalysisModal(),
    );

    if (result != null && result.isNotEmpty) {
      onCartonsDetected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showImageModal(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Icon(Icons.camera_alt),
    );
  }
}
