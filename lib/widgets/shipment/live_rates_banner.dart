import 'package:flutter/material.dart';
import 'package:bockaire/config/feature_flags.dart';

/// Banner to indicate live Shippo production rates
///
/// Displays:
/// - Globe icon for global coverage
/// - "Live Global Rates" message
/// - Safety status (labels enabled/disabled)
class LiveRatesBanner extends StatelessWidget {
  final bool showLabelWarning;

  const LiveRatesBanner({super.key, this.showLabelWarning = true});

  @override
  Widget build(BuildContext context) {
    final featureFlags = FeatureFlags();
    final labelsEnabled = featureFlags.isShippoLabelsEnabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: labelsEnabled
            ? Colors.red.withValues(alpha: 0.15)
            : Colors.blue.withValues(alpha: 0.15),
        border: Border(
          bottom: BorderSide(
            color: labelsEnabled
                ? Colors.red.withValues(alpha: 0.3)
                : Colors.blue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            labelsEnabled ? Icons.warning_amber_rounded : Icons.public,
            color: labelsEnabled ? Colors.red.shade700 : Colors.blue.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelsEnabled
                      ? '⚠️ LABEL PURCHASE ENABLED'
                      : '🌍 Live Global Rates (Shippo Production)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: labelsEnabled
                        ? Colors.red.shade700
                        : Colors.blue.shade700,
                  ),
                ),
                if (showLabelWarning) ...[
                  const SizedBox(height: 4),
                  Text(
                    labelsEnabled
                        ? 'Warning: Real charges may occur. Disable ENABLE_SHIPPO_LABELS.'
                        : 'Real carrier rates worldwide • Safe Mode (no purchases)',
                    style: TextStyle(
                      fontSize: 12,
                      color: labelsEnabled
                          ? Colors.red.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Warning card for dangerous admin features
class AdminFeatureWarning extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onDismiss;

  const AdminFeatureWarning({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.warning_amber_rounded,
    this.color = Colors.orange,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
              color: color,
            ),
        ],
      ),
    );
  }
}

/// Quote card enhancement to show provider info
class QuoteProviderBadge extends StatelessWidget {
  final String provider;
  final bool isLive;

  const QuoteProviderBadge({
    super.key,
    required this.provider,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLive
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isLive
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLive ? Icons.cloud_done : Icons.storage,
            size: 14,
            color: isLive ? Colors.green.shade700 : Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            provider,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isLive ? Colors.green.shade700 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
