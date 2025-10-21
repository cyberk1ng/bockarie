import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bg.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ga.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_it.dart';
import 'app_localizations_lt.dart';
import 'app_localizations_lv.dart';
import 'app_localizations_mt.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('bg'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('es'),
    Locale('et'),
    Locale('fa'),
    Locale('fi'),
    Locale('fr'),
    Locale('ga'),
    Locale('he'),
    Locale('hr'),
    Locale('hu'),
    Locale('it'),
    Locale('lt'),
    Locale('lv'),
    Locale('mt'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('sk'),
    Locale('sl'),
    Locale('sv'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Bockarie'**
  String get appTitle;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// New Shipment navigation label
  ///
  /// In en, this message translates to:
  /// **'New Shipment'**
  String get navNewShipment;

  /// Settings navigation label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Theme mode setting label
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get settingsThemeMode;

  /// Light mode tooltip
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get settingsThemeLightTooltip;

  /// System default theme tooltip
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsThemeSystemTooltip;

  /// Dark mode tooltip
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsThemeDarkTooltip;

  /// Configuration section title
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get settingsConfiguration;

  /// Rate tables setting
  ///
  /// In en, this message translates to:
  /// **'Rate Tables'**
  String get settingsRateTables;

  /// Rate tables subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage carrier rates'**
  String get settingsRateTablesSubtitle;

  /// AI providers setting
  ///
  /// In en, this message translates to:
  /// **'AI Providers'**
  String get settingsAiProviders;

  /// AI providers subtitle
  ///
  /// In en, this message translates to:
  /// **'Configure AI models'**
  String get settingsAiProvidersSubtitle;

  /// About setting
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Language setting title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// Language setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Select app language'**
  String get settingsLanguageSubtitle;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// German language name
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// Chinese language name
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// French language name
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// Spanish language name
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// Italian language name
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// Portuguese language name
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// Dutch language name
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageDutch;

  /// Polish language name
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get languagePolish;

  /// Greek language name
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get languageGreek;

  /// Czech language name
  ///
  /// In en, this message translates to:
  /// **'Czech'**
  String get languageCzech;

  /// Hungarian language name
  ///
  /// In en, this message translates to:
  /// **'Hungarian'**
  String get languageHungarian;

  /// Romanian language name
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get languageRomanian;

  /// Swedish language name
  ///
  /// In en, this message translates to:
  /// **'Swedish'**
  String get languageSwedish;

  /// Danish language name
  ///
  /// In en, this message translates to:
  /// **'Danish'**
  String get languageDanish;

  /// Finnish language name
  ///
  /// In en, this message translates to:
  /// **'Finnish'**
  String get languageFinnish;

  /// Slovak language name
  ///
  /// In en, this message translates to:
  /// **'Slovak'**
  String get languageSlovak;

  /// Bulgarian language name
  ///
  /// In en, this message translates to:
  /// **'Bulgarian'**
  String get languageBulgarian;

  /// Croatian language name
  ///
  /// In en, this message translates to:
  /// **'Croatian'**
  String get languageCroatian;

  /// Lithuanian language name
  ///
  /// In en, this message translates to:
  /// **'Lithuanian'**
  String get languageLithuanian;

  /// Latvian language name
  ///
  /// In en, this message translates to:
  /// **'Latvian'**
  String get languageLatvian;

  /// Slovenian language name
  ///
  /// In en, this message translates to:
  /// **'Slovenian'**
  String get languageSlovenian;

  /// Estonian language name
  ///
  /// In en, this message translates to:
  /// **'Estonian'**
  String get languageEstonian;

  /// Maltese language name
  ///
  /// In en, this message translates to:
  /// **'Maltese'**
  String get languageMaltese;

  /// Irish language name
  ///
  /// In en, this message translates to:
  /// **'Irish'**
  String get languageIrish;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// Turkish language name
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageTurkish;

  /// Hebrew language name
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get languageHebrew;

  /// Persian/Farsi language name
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get languagePersian;

  /// System default language option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefaultLanguage;

  /// Currency setting title
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrencyTitle;

  /// Currency setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Select display currency'**
  String get settingsCurrencySubtitle;

  /// Euro currency name
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyEuro;

  /// US Dollar currency name
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get currencyUsd;

  /// British Pound currency name
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get currencyGbp;

  /// Search hint for language selection
  ///
  /// In en, this message translates to:
  /// **'Search languages...'**
  String get searchHint;

  /// Recent shipments section title
  ///
  /// In en, this message translates to:
  /// **'Recent Shipments'**
  String get titleRecentShipments;

  /// New shipment page title
  ///
  /// In en, this message translates to:
  /// **'New Shipment'**
  String get titleNewShipment;

  /// Shipment details section title
  ///
  /// In en, this message translates to:
  /// **'Shipment Details'**
  String get titleShipmentDetails;

  /// Shipping quotes page title
  ///
  /// In en, this message translates to:
  /// **'Shipping Quotes'**
  String get titleShippingQuotes;

  /// Available quotes section title
  ///
  /// In en, this message translates to:
  /// **'Available Quotes'**
  String get titleAvailableQuotes;

  /// Quote comparison modal title
  ///
  /// In en, this message translates to:
  /// **'Quote Comparison'**
  String get titleQuoteComparison;

  /// Packing optimizer page title
  ///
  /// In en, this message translates to:
  /// **'Packing Optimizer'**
  String get titlePackingOptimizer;

  /// Empty state title when no shipments exist
  ///
  /// In en, this message translates to:
  /// **'No shipments yet'**
  String get emptyStateNoShipments;

  /// Empty state subtitle for first shipment
  ///
  /// In en, this message translates to:
  /// **'Create your first shipment to get started'**
  String get emptyStateCreateFirst;

  /// Empty state when no quotes available
  ///
  /// In en, this message translates to:
  /// **'No Shipping Quotes Available'**
  String get emptyStateNoQuotes;

  /// Origin label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get labelFrom;

  /// Destination label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get labelTo;

  /// Origin city field label
  ///
  /// In en, this message translates to:
  /// **'Origin City'**
  String get labelOriginCity;

  /// Origin postal code field label
  ///
  /// In en, this message translates to:
  /// **'Origin Postal'**
  String get labelOriginPostal;

  /// Destination city field label
  ///
  /// In en, this message translates to:
  /// **'Destination City'**
  String get labelDestinationCity;

  /// Destination postal code field label
  ///
  /// In en, this message translates to:
  /// **'Destination Postal'**
  String get labelDestinationPostal;

  /// Postal code field label
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get labelPostalCode;

  /// Country field label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get labelCountry;

  /// State field label
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get labelState;

  /// City field label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get labelCity;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get labelNotes;

  /// Cartons label
  ///
  /// In en, this message translates to:
  /// **'Cartons'**
  String get labelCartons;

  /// Weight label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get labelWeight;

  /// Length field label
  ///
  /// In en, this message translates to:
  /// **'Length (cm)'**
  String get labelLength;

  /// Width field label
  ///
  /// In en, this message translates to:
  /// **'Width (cm)'**
  String get labelWidth;

  /// Height field label
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get labelHeight;

  /// Weight in kg field label
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get labelWeightKg;

  /// Quantity field label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get labelQuantity;

  /// Item type field label
  ///
  /// In en, this message translates to:
  /// **'Item Type'**
  String get labelItemType;

  /// Carton number label
  ///
  /// In en, this message translates to:
  /// **'Carton {number}'**
  String labelCartonNumber(int number);

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// Add carton button
  ///
  /// In en, this message translates to:
  /// **'Add Carton'**
  String get buttonAddCarton;

  /// Save shipment button
  ///
  /// In en, this message translates to:
  /// **'Save Shipment'**
  String get buttonSaveShipment;

  /// View quotes button
  ///
  /// In en, this message translates to:
  /// **'View Quotes'**
  String get buttonViewQuotes;

  /// Optimize button
  ///
  /// In en, this message translates to:
  /// **'Optimize'**
  String get buttonOptimize;

  /// Book this shipment button
  ///
  /// In en, this message translates to:
  /// **'Book This'**
  String get buttonBookThis;

  /// Details button
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get buttonDetails;

  /// Less details button
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get buttonLess;

  /// Book button
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get buttonBook;

  /// Discard button
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get buttonDiscard;

  /// Save changes button
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get buttonSaveChanges;

  /// Got it button
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get buttonGotIt;

  /// Reset to original button
  ///
  /// In en, this message translates to:
  /// **'Reset to Original'**
  String get buttonResetToOriginal;

  /// Recalculate quotes button
  ///
  /// In en, this message translates to:
  /// **'Recalculate Quotes'**
  String get buttonRecalculateQuotes;

  /// Apply suggestion button
  ///
  /// In en, this message translates to:
  /// **'Apply Suggestion'**
  String get buttonApplySuggestion;

  /// Export PDF action
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get actionExportPdf;

  /// Optimize packing action
  ///
  /// In en, this message translates to:
  /// **'Optimize Packing'**
  String get actionOptimizePacking;

  /// Back button tooltip
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tooltipBack;

  /// Help button tooltip
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get tooltipHelp;

  /// Sort button tooltip
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get tooltipSort;

  /// List view tooltip
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get tooltipListView;

  /// Group by transport method tooltip
  ///
  /// In en, this message translates to:
  /// **'Group by Transport Method'**
  String get tooltipGroupByTransportMethod;

  /// Click to edit hint
  ///
  /// In en, this message translates to:
  /// **'Click to edit'**
  String get hintClickToEdit;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validationRequired;

  /// Invalid field validation message
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get validationInvalid;

  /// Error when no cartons added
  ///
  /// In en, this message translates to:
  /// **'Please add at least one carton'**
  String get errorAddCartons;

  /// Error saving shipment
  ///
  /// In en, this message translates to:
  /// **'Error saving shipment'**
  String get errorSavingShipment;

  /// Error loading shipments
  ///
  /// In en, this message translates to:
  /// **'Error loading shipments'**
  String get errorLoadingShipments;

  /// Error loading cartons
  ///
  /// In en, this message translates to:
  /// **'Error loading cartons'**
  String get errorLoadingCartons;

  /// Error updating address
  ///
  /// In en, this message translates to:
  /// **'Error updating address'**
  String get errorUpdatingAddress;

  /// Error exporting PDF
  ///
  /// In en, this message translates to:
  /// **'Error exporting PDF'**
  String get errorExportingPdf;

  /// Error recalculating quotes
  ///
  /// In en, this message translates to:
  /// **'Error recalculating quotes'**
  String get errorRecalculating;

  /// Error saving changes
  ///
  /// In en, this message translates to:
  /// **'Error saving changes'**
  String get errorSavingChanges;

  /// Error deleting shipment
  ///
  /// In en, this message translates to:
  /// **'Error deleting shipment'**
  String get errorDeletingShipment;

  /// Error applying optimization suggestion
  ///
  /// In en, this message translates to:
  /// **'Error applying suggestion'**
  String get errorApplySuggestion;

  /// Success message for saved shipment
  ///
  /// In en, this message translates to:
  /// **'Shipment saved successfully'**
  String get successShipmentSaved;

  /// Success message for deleted shipment
  ///
  /// In en, this message translates to:
  /// **'Shipment deleted successfully'**
  String get successShipmentDeleted;

  /// Success message for PDF export
  ///
  /// In en, this message translates to:
  /// **'PDF exported successfully'**
  String get successPdfExported;

  /// Success message for saved changes
  ///
  /// In en, this message translates to:
  /// **'Changes saved! Quotes updated.'**
  String get successChangesSaved;

  /// Success message for updated address
  ///
  /// In en, this message translates to:
  /// **'Address updated! {count} quotes generated.'**
  String successAddressUpdated(int count);

  /// Success message when optimization is applied
  ///
  /// In en, this message translates to:
  /// **'Optimization applied! Quotes have been recalculated.'**
  String get successOptimizationApplied;

  /// Status message when calculating quotes
  ///
  /// In en, this message translates to:
  /// **'Calculating quotes...'**
  String get statusCalculatingQuotes;

  /// Loading status
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get statusLoading;

  /// Status when saving shipment
  ///
  /// In en, this message translates to:
  /// **'Saving shipment and generating quotes...'**
  String get statusSavingShipment;

  /// Status when no quotes available
  ///
  /// In en, this message translates to:
  /// **'No quotes available'**
  String get statusNoQuotesAvailable;

  /// Shipment status: in transit
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get statusInTransit;

  /// Shipment status: delivered
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// Shipment status: pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Delete shipment dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Shipment'**
  String get deleteShipmentTitle;

  /// Delete shipment confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the shipment from {origin} to {destination}?'**
  String deleteShipmentMessage(String origin, String destination);

  /// Book shipment dialog title
  ///
  /// In en, this message translates to:
  /// **'Book Shipment'**
  String get bookShipmentTitle;

  /// Book shipment confirmation message
  ///
  /// In en, this message translates to:
  /// **'Book shipment with {carrier} {service}?'**
  String bookShipmentMessage(String carrier, String service);

  /// Booking feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'Booking feature coming soon!'**
  String get bookingFeatureComingSoon;

  /// Edit origin dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Origin'**
  String get editOriginTitle;

  /// Edit destination dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Destination'**
  String get editDestinationTitle;

  /// Edit dimensions dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Dimensions'**
  String get editDimensionsTitle;

  /// Edit dimensions dialog subtitle
  ///
  /// In en, this message translates to:
  /// **'Experiment with different packing configurations'**
  String get editDimensionsSubtitle;

  /// Auto-fill note for address fields
  ///
  /// In en, this message translates to:
  /// **'Country, state, and postal code will be auto-filled when you select a city'**
  String get autoFillNote;

  /// Sort option for price low to high
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get sortPriceLowHigh;

  /// Sort option for price high to low
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get sortPriceHighLow;

  /// Sort option for fastest first
  ///
  /// In en, this message translates to:
  /// **'Speed: Fastest First'**
  String get sortSpeedFastest;

  /// Sort option for slowest first
  ///
  /// In en, this message translates to:
  /// **'Speed: Slowest First'**
  String get sortSpeedSlowest;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Cheapest badge label
  ///
  /// In en, this message translates to:
  /// **'CHEAPEST'**
  String get badgeCheapest;

  /// Fastest badge label
  ///
  /// In en, this message translates to:
  /// **'FASTEST'**
  String get badgeFastest;

  /// Best in category badge label
  ///
  /// In en, this message translates to:
  /// **'BEST IN CATEGORY'**
  String get badgeBestInCategory;

  /// Price breakdown section title
  ///
  /// In en, this message translates to:
  /// **'Price Breakdown'**
  String get quoteDetailsPriceBreakdown;

  /// Chargeable weight label
  ///
  /// In en, this message translates to:
  /// **'Chargeable Weight'**
  String get quoteDetailsChargeableWeight;

  /// Total price label
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get quoteDetailsTotalPrice;

  /// Potential savings label
  ///
  /// In en, this message translates to:
  /// **'Potential Savings!'**
  String get quoteComparisonPotentialSavings;

  /// Cost increase label
  ///
  /// In en, this message translates to:
  /// **'Cost Increase'**
  String get quoteComparisonCostIncrease;

  /// No change label
  ///
  /// In en, this message translates to:
  /// **'No Change'**
  String get quoteComparisonNoChange;

  /// Available quotes with count
  ///
  /// In en, this message translates to:
  /// **'Available Quotes ({count})'**
  String quoteComparisonAvailableQuotes(int count);

  /// No quotes available in comparison
  ///
  /// In en, this message translates to:
  /// **'No Quotes Available'**
  String get quoteComparisonNoQuotesAvailable;

  /// Shippo test API limitation message
  ///
  /// In en, this message translates to:
  /// **'Shippo test API keys don\'t support this shipping route.\n\nTest carrier accounts typically only work for US domestic or China-to-US routes.\n\nTo get real rates for this route, you need to:\n• Switch to live Shippo API keys\n• Connect real carrier accounts (UPS, DHL, FedEx, etc.)'**
  String get shippoTestLimitationMessage;

  /// Short Shippo test limitation message
  ///
  /// In en, this message translates to:
  /// **'Shippo\'s free test carrier accounts don\'t support international shipments from China.'**
  String get shippoTestLimitationShort;

  /// How to get real quotes title
  ///
  /// In en, this message translates to:
  /// **'How to get real shipping quotes:'**
  String get shippoHowToGetRealQuotes;

  /// Step 1 for getting real quotes
  ///
  /// In en, this message translates to:
  /// **'Sign up for carrier accounts (DHL, FedEx, UPS, etc.)'**
  String get shippoStep1;

  /// Step 2 for getting real quotes
  ///
  /// In en, this message translates to:
  /// **'Connect them to your Shippo account'**
  String get shippoStep2;

  /// Step 3 for getting real quotes
  ///
  /// In en, this message translates to:
  /// **'Update your Shippo API key in app settings'**
  String get shippoStep3;

  /// Info header for getting real quotes
  ///
  /// In en, this message translates to:
  /// **'To get real shipping quotes:'**
  String get shippoInfoToGetRealQuotes;

  /// Info step 1
  ///
  /// In en, this message translates to:
  /// **'1. Sign up for carrier accounts (DHL, FedEx, UPS)'**
  String get shippoInfoStep1;

  /// Info step 2
  ///
  /// In en, this message translates to:
  /// **'2. Connect them to your Shippo account'**
  String get shippoInfoStep2;

  /// Info step 3
  ///
  /// In en, this message translates to:
  /// **'3. Update your API key in the app settings'**
  String get shippoInfoStep3;

  /// Warning when no quotes after address update
  ///
  /// In en, this message translates to:
  /// **'Address updated! No quotes available - configure Shippo carrier accounts for real rates.'**
  String get warningNoQuotesConfigureShippo;

  /// Warning when quote generation fails
  ///
  /// In en, this message translates to:
  /// **'Warning: Could not generate quotes: {error}'**
  String warningCouldNotGenerateQuotes(String error);

  /// Current packing section title
  ///
  /// In en, this message translates to:
  /// **'Current Packing'**
  String get optimizerCurrentPacking;

  /// Packing summary title
  ///
  /// In en, this message translates to:
  /// **'Packing Summary'**
  String get optimizerPackingSummary;

  /// Total cartons label
  ///
  /// In en, this message translates to:
  /// **'Total Cartons'**
  String get optimizerTotalCartons;

  /// Actual weight label
  ///
  /// In en, this message translates to:
  /// **'Actual Weight'**
  String get optimizerActualWeight;

  /// Dimensional weight label
  ///
  /// In en, this message translates to:
  /// **'Dimensional Weight'**
  String get optimizerDimensionalWeight;

  /// Chargeable weight label
  ///
  /// In en, this message translates to:
  /// **'Chargeable Weight'**
  String get optimizerChargeableWeight;

  /// Largest side label
  ///
  /// In en, this message translates to:
  /// **'Largest Side'**
  String get optimizerLargestSide;

  /// Oversize warning message
  ///
  /// In en, this message translates to:
  /// **'Oversize detected - extra fees apply'**
  String get optimizerOversizeWarning;

  /// Optimization suggestions section title
  ///
  /// In en, this message translates to:
  /// **'Optimization Suggestions'**
  String get optimizerSuggestions;

  /// Cost saving opportunity title
  ///
  /// In en, this message translates to:
  /// **'Cost Saving Opportunity'**
  String get optimizerCostSavingOpportunity;

  /// Packing optimal message
  ///
  /// In en, this message translates to:
  /// **'Packing looks optimal!'**
  String get optimizerPackingOptimal;

  /// No suggestions message
  ///
  /// In en, this message translates to:
  /// **'Your current packing is efficient. No optimization suggestions at this time.'**
  String get optimizerNoSuggestions;

  /// Carton details section title
  ///
  /// In en, this message translates to:
  /// **'Carton Details'**
  String get optimizerCartonDetails;

  /// Dimensions display
  ///
  /// In en, this message translates to:
  /// **'Dimensions: {length}×{width}×{height} cm'**
  String optimizerDimensions(double length, double width, double height);

  /// Weight display
  ///
  /// In en, this message translates to:
  /// **'Weight: {weight} kg'**
  String optimizerWeight(double weight);

  /// Item type display
  ///
  /// In en, this message translates to:
  /// **'Item: {type}'**
  String optimizerItem(String type);

  /// Optimizer help dialog title
  ///
  /// In en, this message translates to:
  /// **'Packing Optimizer'**
  String get optimizerHelpTitle;

  /// Optimizer help content
  ///
  /// In en, this message translates to:
  /// **'The packing optimizer analyzes your cartons and suggests ways to reduce shipping costs by optimizing dimensions.\n\nKey metrics:\n• Actual Weight: Physical weight of items\n• Dimensional Weight: Calculated from carton size\n• Chargeable Weight: Higher of the two\n\nTip: Reducing carton height often provides the best savings!'**
  String get optimizerHelpContent;

  /// Updated totals preview title
  ///
  /// In en, this message translates to:
  /// **'Updated Totals (Preview)'**
  String get liveTotalsUpdated;

  /// Actual weight label in live totals
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get liveTotalsActual;

  /// Dimensional weight label in live totals
  ///
  /// In en, this message translates to:
  /// **'Dim'**
  String get liveTotalsDim;

  /// Chargeable weight label in live totals
  ///
  /// In en, this message translates to:
  /// **'Chargeable'**
  String get liveTotalsChargeable;

  /// Info note about weight calculations
  ///
  /// In en, this message translates to:
  /// **'Dim Weight = (L×W×H)/5000, Chargeable = max(Actual, Dim) × Qty. Click \"Recalculate Quotes\" to fetch real shipping rates from Shippo API.'**
  String get liveTotalsInfoNote;

  /// Oversize warning in live totals
  ///
  /// In en, this message translates to:
  /// **'Oversize - extra fees may apply'**
  String get liveTotalsOversizeWarning;

  /// Express air transport method
  ///
  /// In en, this message translates to:
  /// **'Express Air'**
  String get transportExpressAir;

  /// Standard air transport method
  ///
  /// In en, this message translates to:
  /// **'Standard Air'**
  String get transportStandardAir;

  /// Air freight transport method
  ///
  /// In en, this message translates to:
  /// **'Air Freight'**
  String get transportAirFreight;

  /// Sea freight LCL transport method
  ///
  /// In en, this message translates to:
  /// **'Sea Freight (LCL)'**
  String get transportSeaFreightLCL;

  /// Sea freight FCL transport method
  ///
  /// In en, this message translates to:
  /// **'Sea Freight (FCL)'**
  String get transportSeaFreightFCL;

  /// Road freight transport method
  ///
  /// In en, this message translates to:
  /// **'Road Freight'**
  String get transportRoadFreight;

  /// Transport method options count
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{option} other{options}}'**
  String transportOptionsCount(int count);

  /// ETA days range
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} days'**
  String etaDays(int min, int max);

  /// ETA in days
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String etaSingleDay(int days);

  /// Weight in kilograms
  ///
  /// In en, this message translates to:
  /// **'{weight} kg'**
  String weightKg(double weight);

  /// Price starting from
  ///
  /// In en, this message translates to:
  /// **'from {price}'**
  String priceFrom(String price);

  /// Cheapest price display
  ///
  /// In en, this message translates to:
  /// **'{weight} kg • from {price}'**
  String cheapestPrice(String weight, String price);

  /// Route display format
  ///
  /// In en, this message translates to:
  /// **'{origin} → {destination}'**
  String routeDisplay(String origin, String destination);

  /// City and postal code display
  ///
  /// In en, this message translates to:
  /// **'{city}, {postal}'**
  String cityPostalDisplay(String city, String postal);

  /// Version display format
  ///
  /// In en, this message translates to:
  /// **'Bockarie v{version} ({buildNumber})'**
  String versionDisplay(String version, String buildNumber);

  /// Cheapest price change display
  ///
  /// In en, this message translates to:
  /// **'Cheapest: {oldPrice} → {newPrice}'**
  String cheapestPriceChange(String oldPrice, String newPrice);

  /// Instant quotes section title
  ///
  /// In en, this message translates to:
  /// **'Instant Quotes'**
  String get instantQuotes;

  /// Chargeable weight display
  ///
  /// In en, this message translates to:
  /// **'{weight} kg chargeable'**
  String chargeableWeightDisplay(String weight);

  /// Cheapest badge short label
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get badgeCheapestShort;

  /// Fastest badge short label
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get badgeFastestShort;

  /// Best value badge label
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get badgeBestValue;

  /// Quote subtotal label
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get quoteSubtotal;

  /// Fuel surcharge label
  ///
  /// In en, this message translates to:
  /// **'Fuel Surcharge'**
  String get quoteFuelSurcharge;

  /// Oversize fee label
  ///
  /// In en, this message translates to:
  /// **'Oversize Fee'**
  String get quoteOversizeFee;

  /// Optimization found title
  ///
  /// In en, this message translates to:
  /// **'Optimization Found!'**
  String get optimizationFoundTitle;

  /// Fewer cartons message
  ///
  /// In en, this message translates to:
  /// **'{count} fewer carton(s)'**
  String fewerCartons(int count);

  /// Less chargeable weight message
  ///
  /// In en, this message translates to:
  /// **'{weight} kg less chargeable weight'**
  String lessChargeableWeight(String weight);

  /// Current packing is optimal message
  ///
  /// In en, this message translates to:
  /// **'Current packing is already optimal'**
  String get currentPackingOptimal;

  /// Current comparison label
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get comparisonCurrent;

  /// Optimized comparison label
  ///
  /// In en, this message translates to:
  /// **'Optimized'**
  String get comparisonOptimized;

  /// Cartons statistic label
  ///
  /// In en, this message translates to:
  /// **'Cartons'**
  String get statCartons;

  /// Chargeable weight statistic label
  ///
  /// In en, this message translates to:
  /// **'Chargeable'**
  String get statChargeable;

  /// Volume statistic label
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get statVolume;

  /// Apply optimization button
  ///
  /// In en, this message translates to:
  /// **'Apply Optimization'**
  String get buttonApplyOptimization;

  /// Keep original button
  ///
  /// In en, this message translates to:
  /// **'Keep Original'**
  String get buttonKeepOriginal;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// Helper text to select from dropdown
  ///
  /// In en, this message translates to:
  /// **'Please select a city from the dropdown'**
  String get helperSelectFromDropdown;

  /// Validation message to select from dropdown
  ///
  /// In en, this message translates to:
  /// **'Please select a city from the dropdown'**
  String get validationSelectFromDropdown;

  /// Button text to get AI recommendations for packing optimization
  ///
  /// In en, this message translates to:
  /// **'Get AI Recommendations'**
  String get optimizerGetAIRecommendations;

  /// Loading message while getting AI recommendations
  ///
  /// In en, this message translates to:
  /// **'Getting AI recommendations...'**
  String get optimizerGettingAIRecommendations;

  /// Title for AI recommendations section
  ///
  /// In en, this message translates to:
  /// **'AI Recommendations'**
  String get optimizerAIRecommendations;

  /// Label for compression advice
  ///
  /// In en, this message translates to:
  /// **'Compression Advice'**
  String get optimizerCompressionAdvice;

  /// Label for estimated savings percentage
  ///
  /// In en, this message translates to:
  /// **'Estimated Savings'**
  String get optimizerEstimatedSavings;

  /// Label for warnings section
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get optimizerWarnings;

  /// Label for tips section
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get optimizerTips;

  /// Label for explanation section
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get optimizerExplanation;

  /// Label for recommended box count
  ///
  /// In en, this message translates to:
  /// **'Recommended Box Count'**
  String get optimizerRecommendedBoxCount;

  /// Error message when trying to optimize with no cartons
  ///
  /// In en, this message translates to:
  /// **'Add cartons first before optimizing'**
  String get errorNoCartonsToOptimize;

  /// Label for optimizer provider setting
  ///
  /// In en, this message translates to:
  /// **'Optimizer Provider'**
  String get settingsOptimizerProvider;

  /// Label for optimizer model setting
  ///
  /// In en, this message translates to:
  /// **'Optimizer Model'**
  String get settingsOptimizerModel;

  /// Label for Ollama base URL setting
  ///
  /// In en, this message translates to:
  /// **'Base URL (Ollama)'**
  String get settingsOptimizerBaseUrl;

  /// Button text to test Ollama connection
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get settingsOptimizerTestConnection;

  /// Warning banner shown when using Shippo test mode
  ///
  /// In en, this message translates to:
  /// **'Test mode: Multi-parcel shipments auto-consolidated. Production will show accurate pricing.'**
  String get shippoTestModeWarning;

  /// Error message when test mode fails due to multi-parcel limitation
  ///
  /// In en, this message translates to:
  /// **'Test mode limitation: Multi-parcel shipments may not return quotes. This will work in production with real carrier accounts. For testing, try setting all quantities to 1.'**
  String get shippoTestMultiParcelLimitation;

  /// Generic test mode no quotes message
  ///
  /// In en, this message translates to:
  /// **'No quotes available in test mode. Some routes or configurations require production carrier accounts. Switch to production mode for real quotes.'**
  String get shippoTestNoQuotes;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bg',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'et',
    'fa',
    'fi',
    'fr',
    'ga',
    'he',
    'hr',
    'hu',
    'it',
    'lt',
    'lv',
    'mt',
    'nl',
    'pl',
    'pt',
    'ro',
    'sk',
    'sl',
    'sv',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bg':
      return AppLocalizationsBg();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'fa':
      return AppLocalizationsFa();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'ga':
      return AppLocalizationsGa();
    case 'he':
      return AppLocalizationsHe();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'it':
      return AppLocalizationsIt();
    case 'lt':
      return AppLocalizationsLt();
    case 'lv':
      return AppLocalizationsLv();
    case 'mt':
      return AppLocalizationsMt();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sv':
      return AppLocalizationsSv();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
