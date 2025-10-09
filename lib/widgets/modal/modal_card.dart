import 'package:flutter/material.dart';
import 'package:bockaire/themes/theme.dart';

/// A card widget specifically designed for use in modals
/// Provides better contrast and visual separation against modal backgrounds
class ModalCard extends StatelessWidget {
  const ModalCard({
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.cardElevation,
      surfaceTintColor: context.colorScheme.surfaceTint,
      color: backgroundColor,
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.cardPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}
