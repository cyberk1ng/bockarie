// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get appTitle => 'Bockarie';

  @override
  String get navHome => 'Home';

  @override
  String get navNewShipment => 'New Shipment';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeMode => 'Theme Mode';

  @override
  String get settingsThemeLightTooltip => 'Light Mode';

  @override
  String get settingsThemeSystemTooltip => 'System Default';

  @override
  String get settingsThemeDarkTooltip => 'Dark Mode';

  @override
  String get settingsConfiguration => 'Configuration';

  @override
  String get settingsRateTables => 'Rate Tables';

  @override
  String get settingsRateTablesSubtitle => 'Manage carrier rates';

  @override
  String get settingsAiProviders => 'AI Providers';

  @override
  String get settingsAiProvidersSubtitle => 'Configure AI models';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Select app language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'German';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageFrench => 'French';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageDutch => 'Dutch';

  @override
  String get languagePolish => 'Polish';

  @override
  String get languageGreek => 'Greek';

  @override
  String get languageCzech => 'Czech';

  @override
  String get languageHungarian => 'Hungarian';

  @override
  String get languageRomanian => 'Romanian';

  @override
  String get languageSwedish => 'Swedish';

  @override
  String get languageDanish => 'Danish';

  @override
  String get languageFinnish => 'Finnish';

  @override
  String get languageSlovak => 'Slovak';

  @override
  String get languageBulgarian => 'Bulgarian';

  @override
  String get languageCroatian => 'Croatian';

  @override
  String get languageLithuanian => 'Lithuanian';

  @override
  String get languageLatvian => 'Latvian';

  @override
  String get languageSlovenian => 'Slovenian';

  @override
  String get languageEstonian => 'Estonian';

  @override
  String get languageMaltese => 'Maltese';

  @override
  String get languageIrish => 'Irish';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get languageHebrew => 'Hebrew';

  @override
  String get languagePersian => 'Persian';

  @override
  String get systemDefaultLanguage => 'System Default';

  @override
  String get settingsCurrencyTitle => 'Currency';

  @override
  String get settingsCurrencySubtitle => 'Select display currency';

  @override
  String get currencyEuro => 'Euro';

  @override
  String get currencyUsd => 'US Dollar';

  @override
  String get currencyGbp => 'British Pound';

  @override
  String get searchHint => 'Search languages...';

  @override
  String get titleRecentShipments => 'Recent Shipments';

  @override
  String get titleNewShipment => 'New Shipment';

  @override
  String get titleShipmentDetails => 'Shipment Details';

  @override
  String get titleShippingQuotes => 'Shipping Quotes';

  @override
  String get titleAvailableQuotes => 'Available Quotes';

  @override
  String get titleQuoteComparison => 'Quote Comparison';

  @override
  String get titlePackingOptimizer => 'Packing Optimizer';

  @override
  String get emptyStateNoShipments => 'No shipments yet';

  @override
  String get emptyStateCreateFirst =>
      'Create your first shipment to get started';

  @override
  String get emptyStateNoQuotes => 'No Shipping Quotes Available';

  @override
  String get labelFrom => 'From';

  @override
  String get labelTo => 'To';

  @override
  String get labelOriginCity => 'Origin City';

  @override
  String get labelOriginPostal => 'Origin Postal';

  @override
  String get labelDestinationCity => 'Destination City';

  @override
  String get labelDestinationPostal => 'Destination Postal';

  @override
  String get labelPostalCode => 'Postal Code';

  @override
  String get labelCountry => 'Country';

  @override
  String get labelState => 'State';

  @override
  String get labelCity => 'City';

  @override
  String get labelNotes => 'Notes (optional)';

  @override
  String get labelCartons => 'Cartons';

  @override
  String get labelWeight => 'Weight';

  @override
  String get labelLength => 'Length (cm)';

  @override
  String get labelWidth => 'Width (cm)';

  @override
  String get labelHeight => 'Height (cm)';

  @override
  String get labelWeightKg => 'Weight (kg)';

  @override
  String get labelQuantity => 'Quantity';

  @override
  String get labelItemType => 'Item Type';

  @override
  String labelCartonNumber(int number) {
    return 'Carton $number';
  }

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonAddCarton => 'Add Carton';

  @override
  String get buttonSaveShipment => 'Save Shipment';

  @override
  String get buttonViewQuotes => 'View Quotes';

  @override
  String get buttonOptimize => 'Optimize';

  @override
  String get buttonBookThis => 'Book This';

  @override
  String get buttonDetails => 'Details';

  @override
  String get buttonLess => 'Less';

  @override
  String get buttonBook => 'Book';

  @override
  String get buttonDiscard => 'Discard';

  @override
  String get buttonSaveChanges => 'Save Changes';

  @override
  String get buttonGotIt => 'Got it';

  @override
  String get buttonResetToOriginal => 'Reset to Original';

  @override
  String get buttonRecalculateQuotes => 'Recalculate Quotes';

  @override
  String get buttonApplySuggestion => 'Apply Suggestion';

  @override
  String get actionExportPdf => 'Export PDF';

  @override
  String get actionOptimizePacking => 'Optimize Packing';

  @override
  String get tooltipBack => 'Back';

  @override
  String get tooltipHelp => 'Help';

  @override
  String get tooltipSort => 'Sort';

  @override
  String get tooltipListView => 'List View';

  @override
  String get tooltipGroupByTransportMethod => 'Group by Transport Method';

  @override
  String get hintClickToEdit => 'Click to edit';

  @override
  String get validationRequired => 'Required';

  @override
  String get validationInvalid => 'Invalid';

  @override
  String get errorAddCartons => 'Please add at least one carton';

  @override
  String get errorSavingShipment => 'Error saving shipment';

  @override
  String get errorLoadingShipments => 'Error loading shipments';

  @override
  String get errorLoadingCartons => 'Error loading cartons';

  @override
  String get errorUpdatingAddress => 'Error updating address';

  @override
  String get errorExportingPdf => 'Error exporting PDF';

  @override
  String get errorRecalculating => 'Error recalculating quotes';

  @override
  String get errorSavingChanges => 'Error saving changes';

  @override
  String get errorDeletingShipment => 'Error deleting shipment';

  @override
  String get errorApplySuggestion => 'Error applying suggestion';

  @override
  String get successShipmentSaved => 'Shipment saved successfully';

  @override
  String get successShipmentDeleted => 'Shipment deleted successfully';

  @override
  String get successPdfExported => 'PDF exported successfully';

  @override
  String get successChangesSaved => 'Changes saved! Quotes updated.';

  @override
  String successAddressUpdated(int count) {
    return 'Address updated! $count quotes generated.';
  }

  @override
  String get successOptimizationApplied =>
      'Optimization applied! Quotes have been recalculated.';

  @override
  String get statusCalculatingQuotes => 'Calculating quotes...';

  @override
  String get statusLoading => 'Loading...';

  @override
  String get statusSavingShipment => 'Saving shipment and generating quotes...';

  @override
  String get statusNoQuotesAvailable => 'No quotes available';

  @override
  String get statusInTransit => 'In Transit';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusPending => 'Pending';

  @override
  String get deleteShipmentTitle => 'Delete Shipment';

  @override
  String deleteShipmentMessage(String origin, String destination) {
    return 'Are you sure you want to delete the shipment from $origin to $destination?';
  }

  @override
  String get bookShipmentTitle => 'Book Shipment';

  @override
  String bookShipmentMessage(String carrier, String service) {
    return 'Book shipment with $carrier $service?';
  }

  @override
  String get bookingFeatureComingSoon => 'Booking feature coming soon!';

  @override
  String get editOriginTitle => 'Edit Origin';

  @override
  String get editDestinationTitle => 'Edit Destination';

  @override
  String get editDimensionsTitle => 'Edit Dimensions';

  @override
  String get editDimensionsSubtitle =>
      'Experiment with different packing configurations';

  @override
  String get autoFillNote =>
      'Country, state, and postal code will be auto-filled when you select a city';

  @override
  String get sortPriceLowHigh => 'Price: Low to High';

  @override
  String get sortPriceHighLow => 'Price: High to Low';

  @override
  String get sortSpeedFastest => 'Speed: Fastest First';

  @override
  String get sortSpeedSlowest => 'Speed: Slowest First';

  @override
  String get filterAll => 'All';

  @override
  String get badgeCheapest => 'CHEAPEST';

  @override
  String get badgeFastest => 'FASTEST';

  @override
  String get badgeBestInCategory => 'BEST IN CATEGORY';

  @override
  String get quoteDetailsPriceBreakdown => 'Price Breakdown';

  @override
  String get quoteDetailsChargeableWeight => 'Chargeable Weight';

  @override
  String get quoteDetailsTotalPrice => 'Total Price';

  @override
  String get quoteComparisonPotentialSavings => 'Potential Savings!';

  @override
  String get quoteComparisonCostIncrease => 'Cost Increase';

  @override
  String get quoteComparisonNoChange => 'No Change';

  @override
  String quoteComparisonAvailableQuotes(int count) {
    return 'Available Quotes ($count)';
  }

  @override
  String get quoteComparisonNoQuotesAvailable => 'No Quotes Available';

  @override
  String get shippoTestLimitationMessage =>
      'Shippo test API keys don\'t support this shipping route.\n\nTest carrier accounts typically only work for US domestic or China-to-US routes.\n\nTo get real rates for this route, you need to:\n• Switch to live Shippo API keys\n• Connect real carrier accounts (UPS, DHL, FedEx, etc.)';

  @override
  String get shippoTestLimitationShort =>
      'Shippo\'s free test carrier accounts don\'t support international shipments from China.';

  @override
  String get shippoHowToGetRealQuotes => 'How to get real shipping quotes:';

  @override
  String get shippoStep1 =>
      'Sign up for carrier accounts (DHL, FedEx, UPS, etc.)';

  @override
  String get shippoStep2 => 'Connect them to your Shippo account';

  @override
  String get shippoStep3 => 'Update your Shippo API key in app settings';

  @override
  String get shippoInfoToGetRealQuotes => 'To get real shipping quotes:';

  @override
  String get shippoInfoStep1 =>
      '1. Sign up for carrier accounts (DHL, FedEx, UPS)';

  @override
  String get shippoInfoStep2 => '2. Connect them to your Shippo account';

  @override
  String get shippoInfoStep3 => '3. Update your API key in the app settings';

  @override
  String get warningNoQuotesConfigureShippo =>
      'Address updated! No quotes available - configure Shippo carrier accounts for real rates.';

  @override
  String warningCouldNotGenerateQuotes(String error) {
    return 'Warning: Could not generate quotes: $error';
  }

  @override
  String get optimizerCurrentPacking => 'Current Packing';

  @override
  String get optimizerPackingSummary => 'Packing Summary';

  @override
  String get optimizerTotalCartons => 'Total Cartons';

  @override
  String get optimizerActualWeight => 'Actual Weight';

  @override
  String get optimizerDimensionalWeight => 'Dimensional Weight';

  @override
  String get optimizerChargeableWeight => 'Chargeable Weight';

  @override
  String get optimizerLargestSide => 'Largest Side';

  @override
  String get optimizerOversizeWarning => 'Oversize detected - extra fees apply';

  @override
  String get optimizerSuggestions => 'Optimization Suggestions';

  @override
  String get optimizerCostSavingOpportunity => 'Cost Saving Opportunity';

  @override
  String get optimizerPackingOptimal => 'Packing looks optimal!';

  @override
  String get optimizerNoSuggestions =>
      'Your current packing is efficient. No optimization suggestions at this time.';

  @override
  String get optimizerCartonDetails => 'Carton Details';

  @override
  String optimizerDimensions(double length, double width, double height) {
    final intl.NumberFormat lengthNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String lengthString = lengthNumberFormat.format(length);
    final intl.NumberFormat widthNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String widthString = widthNumberFormat.format(width);
    final intl.NumberFormat heightNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String heightString = heightNumberFormat.format(height);

    return 'Dimensions: $lengthString×$widthString×$heightString cm';
  }

  @override
  String optimizerWeight(double weight) {
    final intl.NumberFormat weightNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weightString = weightNumberFormat.format(weight);

    return 'Weight: $weightString kg';
  }

  @override
  String optimizerItem(String type) {
    return 'Item: $type';
  }

  @override
  String get optimizerHelpTitle => 'Packing Optimizer';

  @override
  String get optimizerHelpContent =>
      'The packing optimizer analyzes your cartons and suggests ways to reduce shipping costs by optimizing dimensions.\n\nKey metrics:\n• Actual Weight: Physical weight of items\n• Dimensional Weight: Calculated from carton size\n• Chargeable Weight: Higher of the two\n\nTip: Reducing carton height often provides the best savings!';

  @override
  String get liveTotalsUpdated => 'Updated Totals (Preview)';

  @override
  String get liveTotalsActual => 'Actual';

  @override
  String get liveTotalsDim => 'Dim';

  @override
  String get liveTotalsChargeable => 'Chargeable';

  @override
  String get liveTotalsInfoNote =>
      'Dim Weight = (L×W×H)/5000, Chargeable = max(Actual, Dim) × Qty. Click \"Recalculate Quotes\" to fetch real shipping rates from Shippo API.';

  @override
  String get liveTotalsOversizeWarning => 'Oversize - extra fees may apply';

  @override
  String get transportExpressAir => 'Express Air';

  @override
  String get transportStandardAir => 'Standard Air';

  @override
  String get transportAirFreight => 'Air Freight';

  @override
  String get transportSeaFreightLCL => 'Sea Freight (LCL)';

  @override
  String get transportSeaFreightFCL => 'Sea Freight (FCL)';

  @override
  String get transportRoadFreight => 'Road Freight';

  @override
  String transportOptionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'options',
      one: 'option',
    );
    return '$count $_temp0';
  }

  @override
  String etaDays(int min, int max) {
    return '$min-$max days';
  }

  @override
  String etaSingleDay(int days) {
    return '$days days';
  }

  @override
  String weightKg(double weight) {
    final intl.NumberFormat weightNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weightString = weightNumberFormat.format(weight);

    return '$weightString kg';
  }

  @override
  String priceFrom(String price) {
    return 'from $price';
  }

  @override
  String cheapestPrice(String weight, String price) {
    return '$weight kg • from $price';
  }

  @override
  String routeDisplay(String origin, String destination) {
    return '$origin → $destination';
  }

  @override
  String cityPostalDisplay(String city, String postal) {
    return '$city, $postal';
  }

  @override
  String versionDisplay(String version, String buildNumber) {
    return 'Bockarie v$version ($buildNumber)';
  }

  @override
  String cheapestPriceChange(String oldPrice, String newPrice) {
    return 'Cheapest: $oldPrice → $newPrice';
  }

  @override
  String get instantQuotes => 'Instant Quotes';

  @override
  String chargeableWeightDisplay(String weight) {
    return '$weight kg chargeable';
  }

  @override
  String get badgeCheapestShort => 'Cheapest';

  @override
  String get badgeFastestShort => 'Fastest';

  @override
  String get badgeBestValue => 'Best Value';

  @override
  String get quoteSubtotal => 'Subtotal';

  @override
  String get quoteFuelSurcharge => 'Fuel Surcharge';

  @override
  String get quoteOversizeFee => 'Oversize Fee';

  @override
  String get optimizationFoundTitle => 'Optimization Found!';

  @override
  String fewerCartons(int count) {
    return '$count fewer carton(s)';
  }

  @override
  String lessChargeableWeight(String weight) {
    return '$weight kg less chargeable weight';
  }

  @override
  String get currentPackingOptimal => 'Current packing is already optimal';

  @override
  String get comparisonCurrent => 'Current';

  @override
  String get comparisonOptimized => 'Optimized';

  @override
  String get statCartons => 'Cartons';

  @override
  String get statChargeable => 'Chargeable';

  @override
  String get statVolume => 'Volume';

  @override
  String get buttonApplyOptimization => 'Apply Optimization';

  @override
  String get buttonKeepOriginal => 'Keep Original';

  @override
  String get buttonClose => 'Close';

  @override
  String get helperSelectFromDropdown =>
      'Please select a city from the dropdown';

  @override
  String get validationSelectFromDropdown =>
      'Please select a city from the dropdown';

  @override
  String get optimizerGetAIRecommendations => 'Get AI Recommendations';

  @override
  String get optimizerGettingAIRecommendations =>
      'Getting AI recommendations...';

  @override
  String get optimizerAIRecommendations => 'AI Recommendations';

  @override
  String get optimizerCompressionAdvice => 'Compression Advice';

  @override
  String get optimizerEstimatedSavings => 'Estimated Savings';

  @override
  String get optimizerWarnings => 'Warnings';

  @override
  String get optimizerTips => 'Tips';

  @override
  String get optimizerExplanation => 'Explanation';

  @override
  String get optimizerRecommendedBoxCount => 'Recommended Box Count';

  @override
  String get errorNoCartonsToOptimize => 'Add cartons first before optimizing';

  @override
  String get settingsOptimizerProvider => 'Optimizer Provider';

  @override
  String get settingsOptimizerModel => 'Optimizer Model';

  @override
  String get settingsOptimizerBaseUrl => 'Base URL (Ollama)';

  @override
  String get settingsOptimizerTestConnection => 'Test Connection';

  @override
  String get shippoTestModeWarning =>
      'Test mode: Multi-parcel shipments auto-consolidated. Production will show accurate pricing.';

  @override
  String get shippoTestMultiParcelLimitation =>
      'Test mode limitation: Multi-parcel shipments may not return quotes. This will work in production with real carrier accounts. For testing, try setting all quantities to 1.';

  @override
  String get shippoTestNoQuotes =>
      'No quotes available in test mode. Some routes or configurations require production carrier accounts. Switch to production mode for real quotes.';
}
