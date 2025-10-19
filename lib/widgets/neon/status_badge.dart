import 'package:flutter/material.dart';
import 'package:bockaire/themes/neon_theme.dart';
import 'package:bockaire/l10n/app_localizations.dart';

enum ShipmentStatus { inTransit, delivered, pending }

/// A status badge widget with icon and text
class StatusBadge extends StatelessWidget {
  final ShipmentStatus status;
  final Color? color;
  final Color? backgroundColor;

  const StatusBadge({
    super.key,
    required this.status,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on status
    final statusColor = color ?? _getStatusColor();
    final bgColor = backgroundColor ?? _getBackgroundColor(isDark);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: 14, color: statusColor),
          SizedBox(width: 6),
          Text(
            _getStatusText(context),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case ShipmentStatus.inTransit:
        return NeonColors.cyan;
      case ShipmentStatus.delivered:
        return NeonColors.green;
      case ShipmentStatus.pending:
        return NeonColors.purple;
    }
  }

  Color _getBackgroundColor(bool isDark) {
    final statusColor = _getStatusColor();
    return statusColor.withValues(alpha: isDark ? 0.15 : 0.1);
  }

  IconData _getStatusIcon() {
    switch (status) {
      case ShipmentStatus.inTransit:
        return Icons.local_shipping_outlined;
      case ShipmentStatus.delivered:
        return Icons.check_circle_outline;
      case ShipmentStatus.pending:
        return Icons.schedule_outlined;
    }
  }

  String _getStatusText(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case ShipmentStatus.inTransit:
        return localizations.statusInTransit;
      case ShipmentStatus.delivered:
        return localizations.statusDelivered;
      case ShipmentStatus.pending:
        return localizations.statusPending;
    }
  }
}
