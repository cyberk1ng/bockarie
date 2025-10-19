import 'package:flutter/material.dart';
import 'package:bockaire/services/ai_provider_interfaces.dart';
import 'package:bockaire/widgets/voice/voice_input_modal.dart';

class VoiceInputButton extends StatelessWidget {
  final Function(CartonData) onCartonDetected;

  const VoiceInputButton({
    required this.onCartonDetected,
    super.key,
  });

  Future<void> _showVoiceModal(BuildContext context) async {
    final result = await showModalBottomSheet<CartonData>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceInputModal(),
    );

    if (result != null) {
      onCartonDetected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showVoiceModal(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Icon(Icons.mic),
    );
  }
}
