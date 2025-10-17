import 'package:flutter/material.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class ModalUtils {
  static WoltModalType modalTypeBuilder(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    if (size < ModalTheme.pageBreakpoint) {
      return WoltModalType.bottomSheet();
    } else {
      return WoltModalType.dialog();
    }
  }

  static Color getModalBarrierColor({
    required bool isDark,
    required BuildContext context,
  }) {
    return isDark
        ? context.colorScheme.surfaceContainerLow.withAlpha(180)
        : context.colorScheme.outline.withAlpha(128);
  }

  static const defaultPadding = EdgeInsets.all(ModalTheme.padding);

  /// Creates a modern styled modal sheet page
  static WoltModalSheetPage modalSheetPage({
    required BuildContext context,
    required Widget child,
    Widget? stickyActionBar,
    String? title,
    Widget? titleWidget,
    bool isTopBarLayerAlwaysVisible = true,
    bool showCloseButton = true,
    void Function()? onTapBack,
    EdgeInsets padding = defaultPadding,
    double? navBarHeight,
    bool hasTopBarLayer = true,
  }) {
    final colorScheme = context.colorScheme;

    return WoltModalSheetPage(
      stickyActionBar: stickyActionBar,
      backgroundColor: getModalBackgroundColor(context),
      hasSabGradient: false,
      navBarHeight: navBarHeight ?? ModalTheme.navBarHeight,
      hasTopBarLayer: hasTopBarLayer,
      topBarTitle:
          titleWidget ??
          (title != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null),
      isTopBarLayerAlwaysVisible: isTopBarLayerAlwaysVisible,
      leadingNavBarWidget: onTapBack != null
          ? IconButton(
              padding: EdgeInsets.all(ModalTheme.iconPadding),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: ModalTheme.iconSize,
                ),
              ),
              onPressed: onTapBack,
            )
          : null,
      trailingNavBarWidget: showCloseButton
          ? IconButton(
              padding: EdgeInsets.all(ModalTheme.iconPadding),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: ModalTheme.iconSize,
                ),
              ),
              onPressed: Navigator.of(context).pop,
            )
          : null,
      child: Padding(padding: padding, child: child),
    );
  }

  /// Creates a single page modal with modern styling
  static Future<T?> showSinglePageModal<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    String? title,
    Widget? titleWidget,
    Widget? stickyActionBar,
    EdgeInsets padding = defaultPadding,
    double? navBarHeight,
    bool hasTopBarLayer = true,
    bool showCloseButton = true,
    bool barrierDismissible = true,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WoltModalSheet.show<T>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          modalSheetPage(
            stickyActionBar: stickyActionBar,
            title: title,
            titleWidget: titleWidget,
            hasTopBarLayer: hasTopBarLayer,
            navBarHeight: navBarHeight,
            showCloseButton: showCloseButton,
            padding: padding,
            child: builder(modalSheetContext),
            context: modalSheetContext,
          ),
        ];
      },
      modalTypeBuilder: modalTypeBuilder,
      barrierDismissible: barrierDismissible,
      modalBarrierColor: getModalBarrierColor(isDark: isDark, context: context),
    );
  }

  /// Creates a sliver modal sheet page
  static SliverWoltModalSheetPage sliverModalSheetPage({
    required BuildContext context,
    required List<Widget> slivers,
    Widget? stickyActionBar,
    ScrollController? scrollController,
    String? title,
    bool isTopBarLayerAlwaysVisible = true,
    bool showCloseButton = true,
    void Function()? onTapBack,
    double? navBarHeight,
  }) {
    final colorScheme = context.colorScheme;

    return SliverWoltModalSheetPage(
      scrollController: scrollController,
      stickyActionBar: stickyActionBar,
      backgroundColor: getModalBackgroundColor(context),
      hasSabGradient: false,
      useSafeArea: true,
      resizeToAvoidBottomInset: true,
      navBarHeight: navBarHeight ?? ModalTheme.navBarHeight,
      topBarTitle: title != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      isTopBarLayerAlwaysVisible: isTopBarLayerAlwaysVisible,
      leadingNavBarWidget: onTapBack != null
          ? IconButton(
              padding: EdgeInsets.all(ModalTheme.iconPadding),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: ModalTheme.iconSize,
                ),
              ),
              onPressed: onTapBack,
            )
          : null,
      trailingNavBarWidget: showCloseButton
          ? IconButton(
              padding: EdgeInsets.all(ModalTheme.iconPadding),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: ModalTheme.iconSize,
                ),
              ),
              onPressed: Navigator.of(context).pop,
            )
          : null,
      mainContentSliversBuilder: (BuildContext context) {
        return slivers;
      },
    );
  }

  static Color? getModalBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.surfaceContainerHigh;
  }
}
