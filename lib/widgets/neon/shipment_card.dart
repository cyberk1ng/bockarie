import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:bockaire/themes/neon_theme.dart';
import 'package:bockaire/widgets/neon/animated_route_line.dart';
import 'package:bockaire/widgets/neon/status_badge.dart';
import 'package:bockaire/widgets/neon/neon_button.dart';
import 'package:bockaire/l10n/app_localizations.dart';

class ShipmentCardData {
  final String originCity;
  final String originCountry;
  final String destinationCity;
  final String destinationCountry;
  final double weight;
  final double price;
  final String currency;
  final ShipmentStatus status;
  final Color routeColor;

  ShipmentCardData({
    required this.originCity,
    required this.originCountry,
    required this.destinationCity,
    required this.destinationCountry,
    required this.weight,
    required this.price,
    required this.currency,
    required this.status,
    required this.routeColor,
  });
}

/// A futuristic shipment card matching the design
class ShipmentCard extends StatelessWidget {
  final ShipmentCardData data;
  final VoidCallback? onViewQuotes;
  final VoidCallback? onOptimize;

  const ShipmentCard({
    super.key,
    required this.data,
    this.onViewQuotes,
    this.onOptimize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? NeonColors.darkCard : NeonColors.lightCard;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(NeonTheme.borderRadius),
        border: Border.all(
          color: data.routeColor.withValues(alpha: 0.4),
          width: NeonTheme.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: data.routeColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Cities and Route
          Row(
            children: [
              Expanded(
                child: Text(
                  '${data.originCity} > ${data.destinationCity}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              StatusBadge(status: data.status),
            ],
          ),

          SizedBox(height: 20),

          // Route visualization with flags
          RouteWithFlags(
            startFlag: CountryFlag.fromCountryCode(
              data.originCountry,
              width: 48,
              height: 48,
            ),
            endFlag: CountryFlag.fromCountryCode(
              data.destinationCountry,
              width: 48,
              height: 48,
            ),
            lineColor: data.routeColor,
            animate: data.status == ShipmentStatus.inTransit,
          ),

          SizedBox(height: 16),

          // Shipment details
          Row(
            children: [
              Expanded(
                child: Text(
                  '${data.weight.toStringAsFixed(0)} kg • ${_formatCurrency()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? NeonColors.darkText.withValues(alpha: 0.8)
                        : NeonColors.lightText.withValues(alpha: 0.8),
                  ),
                ),
              ),
              _buildActionButton(context),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency() {
    final currencySymbol = _getCurrencySymbol();
    return '$currencySymbol${data.price.toStringAsFixed(0)}';
  }

  String _getCurrencySymbol() {
    switch (data.currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return data.currency;
    }
  }

  Widget _buildActionButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (data.status == ShipmentStatus.inTransit) {
      return NeonButton(
        text: localizations.buttonViewQuotes,
        onPressed: onViewQuotes,
        variant: NeonButtonVariant.outline,
        borderColor: data.routeColor,
        textColor: data.routeColor,
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    } else if (data.status == ShipmentStatus.delivered) {
      return NeonButton(
        text: localizations.buttonOptimize,
        onPressed: onOptimize,
        variant: NeonButtonVariant.outline,
        borderColor: data.routeColor,
        textColor: data.routeColor,
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    } else {
      return NeonButton(
        text: localizations.buttonOptimize,
        onPressed: onOptimize,
        variant: NeonButtonVariant.outline,
        borderColor: data.routeColor,
        textColor: data.routeColor,
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    }
  }
}
