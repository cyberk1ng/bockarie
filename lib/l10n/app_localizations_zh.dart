// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Bockarie';

  @override
  String get navHome => '首页';

  @override
  String get navNewShipment => '新货运';

  @override
  String get navSettings => '设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsThemeMode => '主题模式';

  @override
  String get settingsThemeLightTooltip => '浅色模式';

  @override
  String get settingsThemeSystemTooltip => '系统默认';

  @override
  String get settingsThemeDarkTooltip => '深色模式';

  @override
  String get settingsConfiguration => '配置';

  @override
  String get settingsRateTables => '费率表';

  @override
  String get settingsRateTablesSubtitle => '管理承运商费率';

  @override
  String get settingsAiProviders => 'AI 提供商';

  @override
  String get settingsAiProvidersSubtitle => '配置 AI 模型';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsLanguageTitle => '语言';

  @override
  String get settingsLanguageSubtitle => '选择应用语言';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageGerman => '德语';

  @override
  String get languageChinese => '中文';

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
  String get systemDefaultLanguage => '系统默认';

  @override
  String get settingsCurrencyTitle => '货币';

  @override
  String get settingsCurrencySubtitle => '选择显示货币';

  @override
  String get currencyEuro => '欧元';

  @override
  String get currencyUsd => '美元';

  @override
  String get currencyGbp => '英镑';

  @override
  String get searchHint => '搜索语言...';

  @override
  String get titleRecentShipments => '最近货运';

  @override
  String get titleNewShipment => '新货运';

  @override
  String get titleShipmentDetails => '货运详情';

  @override
  String get titleShippingQuotes => '运费报价';

  @override
  String get titleAvailableQuotes => '可用报价';

  @override
  String get titleQuoteComparison => '报价比较';

  @override
  String get titlePackingOptimizer => '包装优化器';

  @override
  String get emptyStateNoShipments => '还没有货运';

  @override
  String get emptyStateCreateFirst => '创建您的第一个货运以开始';

  @override
  String get emptyStateNoQuotes => '无可用运费报价';

  @override
  String get labelFrom => '发件地';

  @override
  String get labelTo => '收件地';

  @override
  String get labelOriginCity => '始发城市';

  @override
  String get labelOriginPostal => '始发邮编';

  @override
  String get labelDestinationCity => '目的城市';

  @override
  String get labelDestinationPostal => '目的邮编';

  @override
  String get labelPostalCode => '邮政编码';

  @override
  String get labelCountry => '国家';

  @override
  String get labelState => '州/省';

  @override
  String get labelCity => '城市';

  @override
  String get labelNotes => '备注（可选）';

  @override
  String get labelCartons => '纸箱';

  @override
  String get labelWeight => '重量';

  @override
  String get labelLength => '长度（厘米）';

  @override
  String get labelWidth => '宽度（厘米）';

  @override
  String get labelHeight => '高度（厘米）';

  @override
  String get labelWeightKg => '重量（千克）';

  @override
  String get labelQuantity => '数量';

  @override
  String get labelItemType => '物品类型';

  @override
  String labelCartonNumber(int number) {
    return '纸箱 $number';
  }

  @override
  String get buttonSave => '保存';

  @override
  String get buttonCancel => '取消';

  @override
  String get buttonDelete => '删除';

  @override
  String get buttonAddCarton => '添加纸箱';

  @override
  String get buttonSaveShipment => '保存货运';

  @override
  String get buttonViewQuotes => '查看报价';

  @override
  String get buttonOptimize => '优化';

  @override
  String get buttonBookThis => '预订此项';

  @override
  String get buttonDetails => '详情';

  @override
  String get buttonLess => '收起';

  @override
  String get buttonBook => '预订';

  @override
  String get buttonDiscard => '放弃';

  @override
  String get buttonSaveChanges => '保存更改';

  @override
  String get buttonGotIt => '明白了';

  @override
  String get buttonResetToOriginal => '重置为原始';

  @override
  String get buttonRecalculateQuotes => '重新计算报价';

  @override
  String get buttonApplySuggestion => '应用建议';

  @override
  String get actionExportPdf => '导出 PDF';

  @override
  String get actionOptimizePacking => '优化包装';

  @override
  String get tooltipBack => '返回';

  @override
  String get tooltipHelp => '帮助';

  @override
  String get tooltipSort => '排序';

  @override
  String get tooltipListView => '列表视图';

  @override
  String get tooltipGroupByTransportMethod => '按运输方式分组';

  @override
  String get hintClickToEdit => '点击编辑';

  @override
  String get validationRequired => '必填';

  @override
  String get validationInvalid => '无效';

  @override
  String get errorAddCartons => '请至少添加一个纸箱';

  @override
  String get errorSavingShipment => '保存货运出错';

  @override
  String get errorLoadingShipments => '加载货运出错';

  @override
  String get errorLoadingCartons => '加载纸箱出错';

  @override
  String get errorUpdatingAddress => '更新地址出错';

  @override
  String get errorExportingPdf => '导出 PDF 出错';

  @override
  String get errorRecalculating => '重新计算报价出错';

  @override
  String get errorSavingChanges => '保存更改出错';

  @override
  String get errorDeletingShipment => '删除货运出错';

  @override
  String get errorApplySuggestion => '应用建议出错';

  @override
  String get successShipmentSaved => '货运已成功保存';

  @override
  String get successShipmentDeleted => '货运已成功删除';

  @override
  String get successPdfExported => 'PDF 已成功导出';

  @override
  String get successChangesSaved => '更改已保存！报价已更新。';

  @override
  String successAddressUpdated(int count) {
    return '地址已更新！已生成 $count 个报价。';
  }

  @override
  String get successOptimizationApplied => '优化已应用！报价已重新计算。';

  @override
  String get statusCalculatingQuotes => '正在计算报价...';

  @override
  String get statusLoading => '加载中...';

  @override
  String get statusSavingShipment => '正在保存货运并生成报价...';

  @override
  String get statusNoQuotesAvailable => '无可用报价';

  @override
  String get statusInTransit => 'In Transit';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusPending => 'Pending';

  @override
  String get deleteShipmentTitle => '删除货运';

  @override
  String deleteShipmentMessage(String origin, String destination) {
    return '您确定要删除从 $origin 到 $destination 的货运吗？';
  }

  @override
  String get bookShipmentTitle => '预订货运';

  @override
  String bookShipmentMessage(String carrier, String service) {
    return '使用 $carrier $service 预订货运？';
  }

  @override
  String get bookingFeatureComingSoon => '预订功能即将推出！';

  @override
  String get editOriginTitle => '编辑始发地';

  @override
  String get editDestinationTitle => '编辑目的地';

  @override
  String get editDimensionsTitle => '编辑尺寸';

  @override
  String get editDimensionsSubtitle => '尝试不同的包装配置';

  @override
  String get autoFillNote => '选择城市后，国家、州/省和邮政编码将自动填充';

  @override
  String get sortPriceLowHigh => '价格：从低到高';

  @override
  String get sortPriceHighLow => '价格：从高到低';

  @override
  String get sortSpeedFastest => '速度：最快优先';

  @override
  String get sortSpeedSlowest => '速度：最慢优先';

  @override
  String get filterAll => '全部';

  @override
  String get badgeCheapest => '最便宜';

  @override
  String get badgeFastest => '最快';

  @override
  String get badgeBestInCategory => '类别最佳';

  @override
  String get quoteDetailsPriceBreakdown => '价格明细';

  @override
  String get quoteDetailsChargeableWeight => '计费重量';

  @override
  String get quoteDetailsTotalPrice => '总价';

  @override
  String get quoteComparisonPotentialSavings => '可能节省！';

  @override
  String get quoteComparisonCostIncrease => '成本增加';

  @override
  String get quoteComparisonNoChange => '无变化';

  @override
  String quoteComparisonAvailableQuotes(int count) {
    return '可用报价（$count）';
  }

  @override
  String get quoteComparisonNoQuotesAvailable => '无可用报价';

  @override
  String get shippoTestLimitationMessage =>
      'Shippo 测试 API 密钥不支持此运输路线。\n\n测试承运商账户通常仅适用于美国国内或中国到美国的路线。\n\n要获取此路线的实际费率，您需要：\n• 切换到实时 Shippo API 密钥\n• 连接真实的承运商账户（UPS、DHL、FedEx 等）';

  @override
  String get shippoTestLimitationShort => 'Shippo 的免费测试承运商账户不支持来自中国的国际货运。';

  @override
  String get shippoHowToGetRealQuotes => '如何获取真实运费报价：';

  @override
  String get shippoStep1 => '注册承运商账户（DHL、FedEx、UPS 等）';

  @override
  String get shippoStep2 => '将它们连接到您的 Shippo 账户';

  @override
  String get shippoStep3 => '在应用设置中更新您的 Shippo API 密钥';

  @override
  String get shippoInfoToGetRealQuotes => '要获取真实运费报价：';

  @override
  String get shippoInfoStep1 => '1. 注册承运商账户（DHL、FedEx、UPS）';

  @override
  String get shippoInfoStep2 => '2. 将它们连接到您的 Shippo 账户';

  @override
  String get shippoInfoStep3 => '3. 在应用设置中更新您的 API 密钥';

  @override
  String get warningNoQuotesConfigureShippo =>
      '地址已更新！无可用报价 - 配置 Shippo 承运商账户以获取实际费率。';

  @override
  String warningCouldNotGenerateQuotes(String error) {
    return '警告：无法生成报价：$error';
  }

  @override
  String get optimizerCurrentPacking => '当前包装';

  @override
  String get optimizerPackingSummary => '包装摘要';

  @override
  String get optimizerTotalCartons => '总纸箱数';

  @override
  String get optimizerActualWeight => '实际重量';

  @override
  String get optimizerDimensionalWeight => '体积重量';

  @override
  String get optimizerChargeableWeight => '计费重量';

  @override
  String get optimizerLargestSide => '最大边';

  @override
  String get optimizerOversizeWarning => '检测到超大 - 需支付额外费用';

  @override
  String get optimizerSuggestions => '优化建议';

  @override
  String get optimizerCostSavingOpportunity => '节省成本机会';

  @override
  String get optimizerPackingOptimal => '包装看起来最优！';

  @override
  String get optimizerNoSuggestions => '您当前的包装很高效。目前没有优化建议。';

  @override
  String get optimizerCartonDetails => '纸箱详情';

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

    return '尺寸：$lengthString×$widthString×$heightString 厘米';
  }

  @override
  String optimizerWeight(double weight) {
    final intl.NumberFormat weightNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weightString = weightNumberFormat.format(weight);

    return '重量：$weightString 千克';
  }

  @override
  String optimizerItem(String type) {
    return '物品：$type';
  }

  @override
  String get optimizerHelpTitle => '包装优化器';

  @override
  String get optimizerHelpContent =>
      '包装优化器分析您的纸箱并建议通过优化尺寸来降低运输成本的方法。\n\n关键指标：\n• 实际重量：物品的物理重量\n• 体积重量：根据纸箱尺寸计算\n• 计费重量：两者中较高的一个\n\n提示：减少纸箱高度通常可以获得最佳节省！';

  @override
  String get liveTotalsUpdated => '更新的总计（预览）';

  @override
  String get liveTotalsActual => '实际';

  @override
  String get liveTotalsDim => '体积';

  @override
  String get liveTotalsChargeable => '计费';

  @override
  String get liveTotalsInfoNote =>
      '体积重量 = (长×宽×高)/5000，计费重量 = max(实际,体积) × 数量。点击\"重新计算报价\"从 Shippo API 获取实际运费。';

  @override
  String get liveTotalsOversizeWarning => '超大 - 可能收取额外费用';

  @override
  String get transportExpressAir => '航空快递';

  @override
  String get transportStandardAir => '标准航空';

  @override
  String get transportAirFreight => '航空货运';

  @override
  String get transportSeaFreightLCL => '海运拼箱（LCL）';

  @override
  String get transportSeaFreightFCL => '海运整柜（FCL）';

  @override
  String get transportRoadFreight => '公路货运';

  @override
  String transportOptionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '选项',
      one: '选项',
    );
    return '$count 个$_temp0';
  }

  @override
  String etaDays(int min, int max) {
    return '$min-$max 天';
  }

  @override
  String etaSingleDay(int days) {
    return '$days 天';
  }

  @override
  String weightKg(double weight) {
    final intl.NumberFormat weightNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weightString = weightNumberFormat.format(weight);

    return '$weightString 千克';
  }

  @override
  String priceFrom(String price) {
    return '起价 $price';
  }

  @override
  String cheapestPrice(String weight, String price) {
    return '$weight 千克 • 起价 $price';
  }

  @override
  String routeDisplay(String origin, String destination) {
    return '$origin → $destination';
  }

  @override
  String cityPostalDisplay(String city, String postal) {
    return '$city，$postal';
  }

  @override
  String versionDisplay(String version, String buildNumber) {
    return 'Bockarie v$version ($buildNumber)';
  }

  @override
  String cheapestPriceChange(String oldPrice, String newPrice) {
    return '最便宜：$oldPrice → $newPrice';
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

  @override
  String get bookingReviewTitle => 'Review Booking';

  @override
  String get bookingRouteLabel => 'Route';

  @override
  String get bookingCarrierServiceLabel => 'Carrier & Service';

  @override
  String get bookingEstimatedDeliveryLabel => 'Estimated Delivery';

  @override
  String get bookingTotalCostLabel => 'Total Cost';

  @override
  String get bookingCustomsDeclarationReady => 'Customs Declaration Ready';

  @override
  String get bookingCustomsDeclarationRequired =>
      'Customs Declaration Required';

  @override
  String get bookingCustomsRequiredMessage =>
      'International shipments require customs information';

  @override
  String get bookingLabelPurchaseEnabled => 'Label Purchase Enabled';

  @override
  String get bookingSafeMode => 'Safe Mode (No Labels)';

  @override
  String get bookingWillBeCharged =>
      'You will be charged for the shipping label';

  @override
  String get bookingNoChargesTestMode =>
      'No charges will be made - testing mode';

  @override
  String get bookingConfirmButton => 'Confirm Booking';

  @override
  String get bookingEditShipmentDetails => 'Edit Shipment Details';

  @override
  String get bookingConfirmationTitle => 'Booking Confirmation';

  @override
  String get bookingReturnToQuotes => 'Return to Quotes';

  @override
  String get bookingShipmentBooked => '✅ Shipment Booked!';

  @override
  String get bookingShipmentCreated => '📦 Shipment Created';

  @override
  String get bookingLabelGenerated => 'Your shipping label has been generated';

  @override
  String get bookingShipmentCreatedNoLabel =>
      'Shipment created (No label purchased)';

  @override
  String get bookingShipmentDetailsTitle => 'Shipment Details';

  @override
  String get bookingCarrierLabel => 'Carrier';

  @override
  String get bookingShipmentIdLabel => 'Shipment ID';

  @override
  String get bookingTrackingInformation => 'Tracking Information';

  @override
  String get bookingTrackingNumber => 'Tracking Number';

  @override
  String get bookingTrackShipment => 'Track Shipment';

  @override
  String get bookingDocumentsTitle => 'Documents';

  @override
  String get bookingShippingLabel => 'Shipping Label';

  @override
  String get bookingPdfReadyToPrint => 'PDF - Ready to print';

  @override
  String get bookingCommercialInvoice => 'Commercial Invoice';

  @override
  String get bookingPdfCustomsDocument => 'PDF - Customs document';

  @override
  String get bookingCustomsDeclaration => 'Customs Declaration (CN22/CN23)';

  @override
  String get bookingNoDocumentsYet =>
      'No documents generated yet. Documents will be available after label purchase.';

  @override
  String get bookingImportantInformation => 'Important Information';

  @override
  String get bookingLabelGeneratedLiveMode => 'Label Generated (Live Mode)';

  @override
  String get bookingLabelPurchasedMessage =>
      'Your shipping label has been purchased. Print and attach it to your package.';

  @override
  String get bookingSafeModeNoLabel => 'Safe Mode: No Label Purchased';

  @override
  String get bookingSafeModeMessage =>
      'Label creation is disabled in settings (ENABLE_SHIPPO_LABELS=false). No charges were made.';

  @override
  String get safetyConfirmLabelPurchase => 'Confirm Label Purchase';

  @override
  String get safetyWillChargeAccount => 'This will charge your account';

  @override
  String get safetyRealLabelGenerated =>
      '• A real shipping label will be generated\n• Your Shippo account will be charged\n• This action cannot be undone easily\n• Refunds require carrier approval';

  @override
  String get safetyTypeBookToConfirm => 'To confirm, type BOOK below:';

  @override
  String get safetyTypeBookHint => 'Type BOOK to confirm';

  @override
  String get safetyConfirmPurchaseButton => 'Confirm Purchase';

  @override
  String get safetyLiveMode => '⚠️ Live Mode';

  @override
  String get safetySafeMode => '🛡️ Safe Mode';

  @override
  String get safetyLiveModeMessage =>
      'Label creation enabled. Real charges will apply.';

  @override
  String get safetySafeModeMessage =>
      'Labels disabled — Live API active, but no charges will be made.';

  @override
  String get customsDeclarationTitle => 'Customs Declaration';

  @override
  String get customsInternationalShipment => 'International Shipment';

  @override
  String get customsDeclarationRequiredMessage =>
      'Customs declaration required. This information will be used to generate commercial invoice and CN22/CN23 forms.';

  @override
  String get customsLoadSavedProfile => 'Load Saved Profile';

  @override
  String get customsSelectProfile => 'Select Profile';

  @override
  String get customsNoneEnterManually => 'None (Enter manually)';

  @override
  String get customsImporterType => 'Importer Type';

  @override
  String get customsBusinessLabel => 'Business';

  @override
  String get customsIndividualLabel => 'Individual';

  @override
  String get customsTaxIdentification => 'Tax Identification';

  @override
  String get customsVatNumberOptional => 'VAT Number (Optional)';

  @override
  String get customsVatNumberHint => 'e.g., DE123456789';

  @override
  String get customsEoriRequired => 'EORI Number (Required for EU Business)';

  @override
  String get customsEoriOptional => 'EORI Number (Optional)';

  @override
  String get customsEoriHint => 'e.g., GB123456789000';

  @override
  String get customsEoriRequiredValidation =>
      'EORI number required for business importers in EU';

  @override
  String get customsTaxIdOptional => 'Tax ID (Optional)';

  @override
  String get customsTaxIdHint => 'e.g., EIN for US';

  @override
  String get customsCompanyInformation => 'Company Information';

  @override
  String get customsCompanyName => 'Company Name';

  @override
  String get customsCompanyNameRequired =>
      'Company name required for business importers';

  @override
  String get customsContactName => 'Contact Name';

  @override
  String get customsContactPhone => 'Contact Phone';

  @override
  String get customsContactEmail => 'Contact Email';

  @override
  String get customsIncotermsTitle => 'Incoterms';

  @override
  String get customsIncotermsSubtitle =>
      'Delivery terms that define responsibilities between buyer and seller.';

  @override
  String get customsGoodsDeclaration => 'Goods Declaration';

  @override
  String get customsAddItem => 'Add Item';

  @override
  String customsItemNumber(int number) {
    return 'Item $number';
  }

  @override
  String get customsDescriptionRequired => 'Description*';

  @override
  String get customsDescriptionHint => 'e.g., Electronic components';

  @override
  String get customsQuantityRequired => 'Quantity*';

  @override
  String get customsWeightKgRequired => 'Weight (kg)*';

  @override
  String get customsValueUsdRequired => 'Value (USD)*';

  @override
  String get customsHsCodeRequired => 'HS Code*';

  @override
  String get customsHsCodeHint => 'e.g., 8542.31';

  @override
  String get customsOriginCountryRequired => 'Origin Country*';

  @override
  String get customsOriginCountryHint => 'e.g., CN, US';

  @override
  String get customsAdditionalInformation => 'Additional Information';

  @override
  String get customsInvoiceNumberOptional => 'Invoice Number (Optional)';

  @override
  String get customsInvoiceNumberHint => 'e.g., INV-2025-001';

  @override
  String get customsNotesOptional => 'Notes (Optional)';

  @override
  String get customsNotesHint => 'Any additional customs information';

  @override
  String get customsCertifyAccurate =>
      'I certify that the information above is accurate and complete';

  @override
  String get customsCertifySubtitle =>
      'Required for customs declaration. False information may result in penalties.';

  @override
  String get customsSaveProfileFuture =>
      'Save this profile for future shipments';

  @override
  String get customsSaveProfileSubtitle =>
      'Your VAT/EORI and company details will be encrypted and stored locally';

  @override
  String get customsGenerateDocsButton => 'Generate Customs Docs';

  @override
  String get customsFillAllItemsError =>
      'Please fill in all commodity line items with description and HS code';

  @override
  String get customsMustCertifyError =>
      'You must certify that the information is accurate';

  @override
  String get customsInformationSaved => 'Customs information saved';
}
