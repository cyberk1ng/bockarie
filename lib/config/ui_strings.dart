/// User-facing strings for localization and consistency
class UIStrings {
  UIStrings._();

  // Error messages
  static const String errorAddCartons = 'Please add at least one carton';
  static const String errorSavingShipment = 'Error saving shipment';
  static const String errorUpdatingAddress = 'Error updating address';
  static const String errorExportingPdf = 'Error exporting PDF';
  static const String errorRecalculating = 'Error recalculating quotes';
  static const String errorSavingChanges = 'Error saving changes';
  static const String errorRequestTimeout =
      'Request timeout. Please check your internet connection.';
  static const String errorCitySearch = 'City search error';

  // Success messages
  static const String successShipmentSaved = 'Shipment saved successfully';
  static const String successPdfExported = 'PDF exported successfully';
  static const String successChangesSaved = 'Changes saved! Quotes updated.';
  static String successAddressUpdated(int quoteCount) =>
      'Address updated! $quoteCount quotes generated.';

  // Page titles
  static const String titleShippingQuotes = 'Shipping Quotes';
  static const String titleNewShipment = 'New Shipment';
  static const String titleShipmentDetails = 'Shipment Details';
  static const String titleAvailableQuotes = 'Available Quotes';
  static const String titleQuoteComparison = 'Quote Comparison';

  // Labels
  static const String labelFrom = 'From';
  static const String labelTo = 'To';
  static const String labelOrigin = 'Origin';
  static const String labelDestination = 'Destination';
  static const String labelCartons = 'Cartons';
  static const String labelWeight = 'Weight';

  // Actions
  static const String actionExportPdf = 'Export PDF';
  static const String actionOptimizePacking = 'Optimize Packing';

  // PDF strings
  static const String pdfTitleComparison = 'Shipping Quote Comparison';
  static const String pdfSectionShipment = 'Shipment Details';
  static const String pdfSectionQuotes = 'Quote Comparison';
  static const String pdfBestOption = 'Best Option (Lowest Price)';
  static const String pdfNoteEstimates =
      'Note: Prices are estimates and may vary based on actual package dimensions and current carrier rates.';

  // Transport method API limitations
  static const String errorShippoTestLimitation =
      'Shippo test API keys don\'t support this shipping route.\n\n'
      'Test carrier accounts typically only work for US domestic or China-to-US routes.\n\n'
      'To get real rates for this route, you need to:\n'
      '• Switch to live Shippo API keys\n'
      '• Connect real carrier accounts (UPS, DHL, FedEx, etc.)';
}
