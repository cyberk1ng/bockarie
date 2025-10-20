// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Bockarie';

  @override
  String get navHome => 'Inicio';

  @override
  String get navNewShipment => 'Nuevo Envío';

  @override
  String get navSettings => 'Configuración';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsThemeMode => 'Modo de Tema';

  @override
  String get settingsThemeLightTooltip => 'Modo Claro';

  @override
  String get settingsThemeSystemTooltip => 'Predeterminado del Sistema';

  @override
  String get settingsThemeDarkTooltip => 'Modo Oscuro';

  @override
  String get settingsConfiguration => 'Configuración';

  @override
  String get settingsRateTables => 'Tablas de Tarifas';

  @override
  String get settingsRateTablesSubtitle =>
      'Gestionar tarifas de transportistas';

  @override
  String get settingsAiProviders => 'Proveedores de IA';

  @override
  String get settingsAiProvidersSubtitle => 'Configurar modelos de IA';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Seleccionar idioma de la aplicación';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get languageChinese => 'Chino';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get languageDutch => 'Neerlandés';

  @override
  String get languagePolish => 'Polaco';

  @override
  String get languageGreek => 'Griego';

  @override
  String get languageCzech => 'Checo';

  @override
  String get languageHungarian => 'Húngaro';

  @override
  String get languageRomanian => 'Rumano';

  @override
  String get languageSwedish => 'Sueco';

  @override
  String get languageDanish => 'Danés';

  @override
  String get languageFinnish => 'Finlandés';

  @override
  String get languageSlovak => 'Eslovaco';

  @override
  String get languageBulgarian => 'Búlgaro';

  @override
  String get languageCroatian => 'Croata';

  @override
  String get languageLithuanian => 'Lituano';

  @override
  String get languageLatvian => 'Letón';

  @override
  String get languageSlovenian => 'Esloveno';

  @override
  String get languageEstonian => 'Estonio';

  @override
  String get languageMaltese => 'Maltés';

  @override
  String get languageIrish => 'Irlandés';

  @override
  String get languageArabic => 'Árabe';

  @override
  String get languageTurkish => 'Turco';

  @override
  String get languageHebrew => 'Hebreo';

  @override
  String get languagePersian => 'Persa';

  @override
  String get systemDefaultLanguage => 'Predeterminado del Sistema';

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
  String get searchHint => 'Buscar idiomas...';

  @override
  String get titleRecentShipments => 'Envíos Recientes';

  @override
  String get titleNewShipment => 'Nuevo Envío';

  @override
  String get titleShipmentDetails => 'Detalles del Envío';

  @override
  String get titleShippingQuotes => 'Cotizaciones de Envío';

  @override
  String get titleAvailableQuotes => 'Cotizaciones Disponibles';

  @override
  String get titleQuoteComparison => 'Comparación de Cotizaciones';

  @override
  String get titlePackingOptimizer => 'Optimizador de Embalaje';

  @override
  String get emptyStateNoShipments => 'Aún no hay envíos';

  @override
  String get emptyStateCreateFirst => 'Crea tu primer envío para comenzar';

  @override
  String get emptyStateNoQuotes => 'No Hay Cotizaciones de Envío Disponibles';

  @override
  String get labelFrom => 'Desde';

  @override
  String get labelTo => 'Hasta';

  @override
  String get labelOriginCity => 'Ciudad de Origen';

  @override
  String get labelOriginPostal => 'Código Postal de Origen';

  @override
  String get labelDestinationCity => 'Ciudad de Destino';

  @override
  String get labelDestinationPostal => 'Código Postal de Destino';

  @override
  String get labelPostalCode => 'Código Postal';

  @override
  String get labelCountry => 'País';

  @override
  String get labelState => 'Estado';

  @override
  String get labelCity => 'Ciudad';

  @override
  String get labelNotes => 'Notas (opcional)';

  @override
  String get labelCartons => 'Cajas';

  @override
  String get labelWeight => 'Peso';

  @override
  String get labelLength => 'Longitud (cm)';

  @override
  String get labelWidth => 'Ancho (cm)';

  @override
  String get labelHeight => 'Altura (cm)';

  @override
  String get labelWeightKg => 'Peso (kg)';

  @override
  String get labelQuantity => 'Cantidad';

  @override
  String get labelItemType => 'Tipo de Artículo';

  @override
  String labelCartonNumber(int number) {
    return 'Caja $number';
  }

  @override
  String get buttonSave => 'Guardar';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonDelete => 'Eliminar';

  @override
  String get buttonAddCarton => 'Agregar Caja';

  @override
  String get buttonSaveShipment => 'Guardar Envío';

  @override
  String get buttonViewQuotes => 'Ver Cotizaciones';

  @override
  String get buttonOptimize => 'Optimizar';

  @override
  String get buttonBookThis => 'Reservar Este';

  @override
  String get buttonDetails => 'Detalles';

  @override
  String get buttonLess => 'Menos';

  @override
  String get buttonBook => 'Reservar';

  @override
  String get buttonDiscard => 'Descartar';

  @override
  String get buttonSaveChanges => 'Guardar Cambios';

  @override
  String get buttonGotIt => 'Entendido';

  @override
  String get buttonResetToOriginal => 'Restablecer al Original';

  @override
  String get buttonRecalculateQuotes => 'Recalcular Cotizaciones';

  @override
  String get buttonApplySuggestion => 'Aplicar Sugerencia';

  @override
  String get actionExportPdf => 'Exportar PDF';

  @override
  String get actionOptimizePacking => 'Optimizar Embalaje';

  @override
  String get tooltipBack => 'Atrás';

  @override
  String get tooltipHelp => 'Ayuda';

  @override
  String get tooltipSort => 'Ordenar';

  @override
  String get tooltipListView => 'Vista de Lista';

  @override
  String get tooltipGroupByTransportMethod =>
      'Agrupar por Método de Transporte';

  @override
  String get hintClickToEdit => 'Haz clic para editar';

  @override
  String get validationRequired => 'Requerido';

  @override
  String get validationInvalid => 'Inválido';

  @override
  String get errorAddCartons => 'Por favor agrega al menos una caja';

  @override
  String get errorSavingShipment => 'Error al guardar el envío';

  @override
  String get errorLoadingShipments => 'Error al cargar los envíos';

  @override
  String get errorLoadingCartons => 'Error al cargar las cajas';

  @override
  String get errorUpdatingAddress => 'Error al actualizar la dirección';

  @override
  String get errorExportingPdf => 'Error al exportar PDF';

  @override
  String get errorRecalculating => 'Error al recalcular las cotizaciones';

  @override
  String get errorSavingChanges => 'Error al guardar los cambios';

  @override
  String get errorDeletingShipment => 'Error al eliminar el envío';

  @override
  String get errorApplySuggestion => 'Error al aplicar la sugerencia';

  @override
  String get successShipmentSaved => 'Envío guardado exitosamente';

  @override
  String get successShipmentDeleted => 'Envío eliminado exitosamente';

  @override
  String get successPdfExported => 'PDF exportado exitosamente';

  @override
  String get successChangesSaved =>
      '¡Cambios guardados! Cotizaciones actualizadas.';

  @override
  String successAddressUpdated(int count) {
    return '¡Dirección actualizada! $count cotizaciones generadas.';
  }

  @override
  String get successOptimizationApplied =>
      '¡Optimización aplicada! Las cotizaciones han sido recalculadas.';

  @override
  String get statusCalculatingQuotes => 'Calculando cotizaciones...';

  @override
  String get statusLoading => 'Cargando...';

  @override
  String get statusSavingShipment =>
      'Guardando envío y generando cotizaciones...';

  @override
  String get statusNoQuotesAvailable => 'No hay cotizaciones disponibles';

  @override
  String get statusInTransit => 'In Transit';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusPending => 'Pending';

  @override
  String get deleteShipmentTitle => 'Eliminar Envío';

  @override
  String deleteShipmentMessage(String origin, String destination) {
    return '¿Estás seguro de que deseas eliminar el envío de $origin a $destination?';
  }

  @override
  String get bookShipmentTitle => 'Reservar Envío';

  @override
  String bookShipmentMessage(String carrier, String service) {
    return '¿Reservar envío con $carrier $service?';
  }

  @override
  String get bookingFeatureComingSoon => '¡Función de reserva próximamente!';

  @override
  String get editOriginTitle => 'Editar Origen';

  @override
  String get editDestinationTitle => 'Editar Destino';

  @override
  String get editDimensionsTitle => 'Editar Dimensiones';

  @override
  String get editDimensionsSubtitle =>
      'Experimenta con diferentes configuraciones de embalaje';

  @override
  String get autoFillNote =>
      'El país, estado y código postal se completarán automáticamente cuando selecciones una ciudad';

  @override
  String get sortPriceLowHigh => 'Precio: De Menor a Mayor';

  @override
  String get sortPriceHighLow => 'Precio: De Mayor a Menor';

  @override
  String get sortSpeedFastest => 'Velocidad: Más Rápido Primero';

  @override
  String get sortSpeedSlowest => 'Velocidad: Más Lento Primero';

  @override
  String get filterAll => 'Todos';

  @override
  String get badgeCheapest => 'MÁS ECONÓMICO';

  @override
  String get badgeFastest => 'MÁS RÁPIDO';

  @override
  String get badgeBestInCategory => 'MEJOR DE LA CATEGORÍA';

  @override
  String get quoteDetailsPriceBreakdown => 'Desglose de Precios';

  @override
  String get quoteDetailsChargeableWeight => 'Peso Cobrable';

  @override
  String get quoteDetailsTotalPrice => 'Precio Total';

  @override
  String get quoteComparisonPotentialSavings => '¡Ahorros Potenciales!';

  @override
  String get quoteComparisonCostIncrease => 'Aumento de Costo';

  @override
  String get quoteComparisonNoChange => 'Sin Cambios';

  @override
  String quoteComparisonAvailableQuotes(int count) {
    return 'Cotizaciones Disponibles ($count)';
  }

  @override
  String get quoteComparisonNoQuotesAvailable =>
      'No Hay Cotizaciones Disponibles';

  @override
  String get shippoTestLimitationMessage =>
      'Las claves API de prueba de Shippo no admiten esta ruta de envío.\n\nLas cuentas de transportista de prueba generalmente solo funcionan para rutas domésticas de EE. UU. o de China a EE. UU.\n\nPara obtener tarifas reales para esta ruta, necesitas:\n• Cambiar a claves API de Shippo en vivo\n• Conectar cuentas de transportista reales (UPS, DHL, FedEx, etc.)';

  @override
  String get shippoTestLimitationShort =>
      'Las cuentas de transportista de prueba gratuitas de Shippo no admiten envíos internacionales desde China.';

  @override
  String get shippoHowToGetRealQuotes =>
      'Cómo obtener cotizaciones de envío reales:';

  @override
  String get shippoStep1 =>
      'Regístrate en cuentas de transportista (DHL, FedEx, UPS, etc.)';

  @override
  String get shippoStep2 => 'Conéctalas a tu cuenta de Shippo';

  @override
  String get shippoStep3 =>
      'Actualiza tu clave API de Shippo en la configuración de la aplicación';

  @override
  String get shippoInfoToGetRealQuotes =>
      'Para obtener cotizaciones de envío reales:';

  @override
  String get shippoInfoStep1 =>
      '1. Regístrate en cuentas de transportista (DHL, FedEx, UPS)';

  @override
  String get shippoInfoStep2 => '2. Conéctalas a tu cuenta de Shippo';

  @override
  String get shippoInfoStep3 =>
      '3. Actualiza tu clave API en la configuración de la aplicación';

  @override
  String get warningNoQuotesConfigureShippo =>
      '¡Dirección actualizada! No hay cotizaciones disponibles - configura las cuentas de transportista de Shippo para tarifas reales.';

  @override
  String warningCouldNotGenerateQuotes(String error) {
    return 'Advertencia: No se pudieron generar cotizaciones: $error';
  }

  @override
  String get optimizerCurrentPacking => 'Embalaje Actual';

  @override
  String get optimizerPackingSummary => 'Resumen de Embalaje';

  @override
  String get optimizerTotalCartons => 'Total de Cajas';

  @override
  String get optimizerActualWeight => 'Peso Real';

  @override
  String get optimizerDimensionalWeight => 'Peso Volumétrico';

  @override
  String get optimizerChargeableWeight => 'Peso Cobrable';

  @override
  String get optimizerLargestSide => 'Lado Más Grande';

  @override
  String get optimizerOversizeWarning =>
      'Tamaño excesivo detectado - se aplican tarifas adicionales';

  @override
  String get optimizerSuggestions => 'Sugerencias de Optimización';

  @override
  String get optimizerCostSavingOpportunity =>
      'Oportunidad de Ahorro de Costos';

  @override
  String get optimizerPackingOptimal => '¡El embalaje parece óptimo!';

  @override
  String get optimizerNoSuggestions =>
      'Tu embalaje actual es eficiente. No hay sugerencias de optimización en este momento.';

  @override
  String get optimizerCartonDetails => 'Detalles de la Caja';

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

    return 'Dimensiones: $lengthString×$widthString×$heightString cm';
  }

  @override
  String optimizerWeight(double weight) {
    final intl.NumberFormat weightNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weightString = weightNumberFormat.format(weight);

    return 'Peso: $weightString kg';
  }

  @override
  String optimizerItem(String type) {
    return 'Artículo: $type';
  }

  @override
  String get optimizerHelpTitle => 'Optimizador de Embalaje';

  @override
  String get optimizerHelpContent =>
      'El optimizador de embalaje analiza tus cajas y sugiere formas de reducir los costos de envío optimizando las dimensiones.\n\nMétricas clave:\n• Peso Real: Peso físico de los artículos\n• Peso Volumétrico: Calculado a partir del tamaño de la caja\n• Peso Cobrable: El mayor de los dos\n\n¡Consejo: Reducir la altura de la caja a menudo proporciona los mejores ahorros!';

  @override
  String get liveTotalsUpdated => 'Totales Actualizados (Vista Previa)';

  @override
  String get liveTotalsActual => 'Real';

  @override
  String get liveTotalsDim => 'Vol';

  @override
  String get liveTotalsChargeable => 'Cobrable';

  @override
  String get liveTotalsInfoNote =>
      'Peso Vol = (L×A×Al)/5000, Cobrable = máx(Real, Vol) × Cant. Haz clic en \"Recalcular Cotizaciones\" para obtener tarifas de envío reales de la API de Shippo.';

  @override
  String get liveTotalsOversizeWarning =>
      'Tamaño excesivo - pueden aplicarse tarifas adicionales';

  @override
  String get transportExpressAir => 'Aéreo Exprés';

  @override
  String get transportStandardAir => 'Aéreo Estándar';

  @override
  String get transportAirFreight => 'Carga Aérea';

  @override
  String get transportSeaFreightLCL => 'Carga Marítima (LCL)';

  @override
  String get transportSeaFreightFCL => 'Carga Marítima (FCL)';

  @override
  String get transportRoadFreight => 'Carga por Carretera';

  @override
  String transportOptionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'opciones',
      one: 'opción',
    );
    return '$count $_temp0';
  }

  @override
  String etaDays(int min, int max) {
    return '$min-$max días';
  }

  @override
  String etaSingleDay(int days) {
    return '$days días';
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
    return 'desde $price';
  }

  @override
  String cheapestPrice(String weight, String price) {
    return '$weight kg • desde $price';
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
    return 'Más económico: $oldPrice → $newPrice';
  }

  @override
  String get instantQuotes => 'Cotizaciones Instantáneas';

  @override
  String chargeableWeightDisplay(String weight) {
    return '$weight kg cobrable';
  }

  @override
  String get badgeCheapestShort => 'Más Económico';

  @override
  String get badgeFastestShort => 'Más Rápido';

  @override
  String get badgeBestValue => 'Mejor Valor';

  @override
  String get quoteSubtotal => 'Subtotal';

  @override
  String get quoteFuelSurcharge => 'Recargo por Combustible';

  @override
  String get quoteOversizeFee => 'Tarifa por Tamaño Excesivo';

  @override
  String get optimizationFoundTitle => '¡Optimización Encontrada!';

  @override
  String fewerCartons(int count) {
    return '$count caja(s) menos';
  }

  @override
  String lessChargeableWeight(String weight) {
    return '$weight kg menos de peso cobrable';
  }

  @override
  String get currentPackingOptimal => 'El embalaje actual ya es óptimo';

  @override
  String get comparisonCurrent => 'Actual';

  @override
  String get comparisonOptimized => 'Optimizado';

  @override
  String get statCartons => 'Cajas';

  @override
  String get statChargeable => 'Cobrable';

  @override
  String get statVolume => 'Volumen';

  @override
  String get buttonApplyOptimization => 'Aplicar Optimización';

  @override
  String get buttonKeepOriginal => 'Mantener Original';

  @override
  String get buttonClose => 'Cerrar';

  @override
  String get helperSelectFromDropdown =>
      'Por favor selecciona una ciudad del menú desplegable';

  @override
  String get validationSelectFromDropdown =>
      'Por favor selecciona una ciudad del menú desplegable';

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
