/// Database configuration constants
class DatabaseConstants {
  DatabaseConstants._();

  static const String databaseFileName = 'bockaire.sqlite';
  static const int schemaVersion = 6;
  static const String defaultEmptyString = '';

  // Table names (for queries)
  static const String shipmentsTable = 'shipments';
  static const String cartonsTable = 'cartons';
  static const String rateTablesTable = 'rate_tables';
  static const String quotesTable = 'quotes';
  static const String companyInfoTable = 'company_info';
  static const String settingsTable = 'settings';
}
