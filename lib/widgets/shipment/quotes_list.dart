import 'package:flutter/material.dart';
import 'package:bockaire/services/quote_calculator_service.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';
import 'package:bockaire/l10n/app_localizations.dart';

/// Quotes list with badges for best options
class QuotesList extends StatelessWidget {
  final List<ShippingQuote> quotes;
  final QuoteBadges badges;

  const QuotesList({required this.quotes, required this.badges, super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (quotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: context.colorScheme.onSurfaceVariant.withAlpha(100),
              ),
              SizedBox(height: AppTheme.spacingMedium),
              Text(
                localizations.statusNoQuotesAvailable,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.instantQuotes, style: context.textTheme.titleLarge),
        SizedBox(height: AppTheme.spacingMedium),
        ...quotes.map(
          (quote) => Padding(
            padding: EdgeInsets.only(bottom: AppTheme.cardSpacing),
            child: _QuoteCard(quote: quote, badges: badges),
          ),
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final ShippingQuote quote;
  final QuoteBadges badges;

  const _QuoteCard({required this.quote, required this.badges});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isCheapest = badges.isCheapest(quote);
    final isFastest = badges.isFastest(quote);
    final isBestValue = badges.isBestValue(quote);

    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.displayName,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      localizations.chargeableWeightDisplay(
                        quote.chargeableKg.toStringAsFixed(1),
                      ),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '€${quote.total.toStringAsFixed(2)}',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ),

          // Badges
          if (isCheapest || isFastest || isBestValue) ...[
            SizedBox(height: AppTheme.spacingSmall),
            Wrap(
              spacing: AppTheme.spacingSmall,
              runSpacing: AppTheme.spacingSmall,
              children: [
                if (isCheapest)
                  _Badge(
                    label: localizations.badgeCheapestShort,
                    icon: Icons.price_check,
                    color: Colors.green,
                  ),
                if (isFastest)
                  _Badge(
                    label: localizations.badgeFastestShort,
                    icon: Icons.rocket_launch,
                    color: Colors.orange,
                  ),
                if (isBestValue && !isCheapest)
                  _Badge(
                    label: localizations.badgeBestValue,
                    icon: Icons.star,
                    color: Colors.blue,
                  ),
              ],
            ),
          ],

          // Breakdown
          SizedBox(height: AppTheme.spacingMedium),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
            ),
            child: Column(
              children: [
                _buildBreakdownRow(
                  context,
                  localizations.quoteSubtotal,
                  quote.subtotal,
                ),
                _buildBreakdownRow(
                  context,
                  localizations.quoteFuelSurcharge,
                  quote.fuelSurcharge,
                ),
                if (quote.oversizeFee > 0)
                  _buildBreakdownRow(
                    context,
                    localizations.quoteOversizeFee,
                    quote.oversizeFee,
                    isWarning: true,
                  ),
              ],
            ),
          ),

          // Notes
          if (quote.notes != null) ...[
            SizedBox(height: AppTheme.spacingSmall),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: Text(
                    quote.notes!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context,
    String label,
    double amount, {
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: isWarning
                  ? context.colorScheme.error
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '€${amount.toStringAsFixed(2)}',
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isWarning
                  ? context.colorScheme.error
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Badge({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
