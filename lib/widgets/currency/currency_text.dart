import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/providers/currency_provider.dart';

/// Widget that displays amount in current user currency
class CurrencyText extends ConsumerWidget {
  const CurrencyText({
    required this.amountInEur,
    this.style,
    this.decimals = 2,
    super.key,
  });

  final double amountInEur;
  final TextStyle? style;
  final int decimals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyNotifierProvider);
    final service = ref.watch(currencyServiceProvider);

    final formatted = service.formatAmount(
      amountInEur: amountInEur,
      currency: currency,
      decimals: decimals,
    );

    return Text(formatted, style: style);
  }
}
