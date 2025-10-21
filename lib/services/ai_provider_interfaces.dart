import 'dart:convert';
import 'dart:io';
import 'package:bockaire/classes/carton.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';

/// Base interface for AI providers
abstract class AiProvider {
  String get name;
  bool get isAvailable;
}

/// Interface for image-to-cartons extraction
abstract class AiImageAnalyzer extends AiProvider {
  /// Extract carton data from a packing list image
  Future<List<CartonData>> extractCartonsFromImage(File imageFile);
}

/// Interface for voice-to-text transcription
abstract class AiTranscriber extends AiProvider {
  /// Transcribe audio to text
  Future<String> transcribe(File audioFile);

  /// Parse transcribed text into carton commands
  Future<List<CartonData>> parseCartonCommands(String text);
}

/// Interface for cost explanation generation
abstract class AiCostExplainer extends AiProvider {
  /// Generate explanation for shipping cost
  Future<String> explainCost({
    required double totalCost,
    required double chargeableKg,
    required String carrier,
    required String service,
    required Map<String, dynamic> breakdown,
  });
}

/// Item data within a carton
class ItemData {
  final String itemType;
  final int qty;

  const ItemData({required this.itemType, required this.qty});

  factory ItemData.fromJson(Map<String, dynamic> json) => ItemData(
    itemType: json['itemType'] as String? ?? 'Unknown',
    qty: json['qty'] != null ? (json['qty'] as num).toInt() : 0,
  );

  Map<String, dynamic> toJson() => {'itemType': itemType, 'qty': qty};

  @override
  String toString() => '$itemType ($qty)';
}

/// Unit information for detected measurements
class DetectedUnits {
  final String dimensions;
  final String weight;

  const DetectedUnits({required this.dimensions, required this.weight});

  factory DetectedUnits.fromJson(Map<String, dynamic> json) => DetectedUnits(
    dimensions: json['dimensions'] as String? ?? 'cm',
    weight: json['weight'] as String? ?? 'kg',
  );

  Map<String, dynamic> toJson() => {'dimensions': dimensions, 'weight': weight};
}

/// Carton data extracted from AI
class CartonData {
  // New fields (CTN-based format)
  final String? ctnNo;
  final List<ItemData>? items;
  final int? totalQty;
  final double? confidence;
  final DetectedUnits? detectedUnits;

  // Legacy fields (backward compatibility)
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final double? weightKg;
  final int? qty;
  final String? itemType;

  const CartonData({
    // New fields
    this.ctnNo,
    this.items,
    this.totalQty,
    this.confidence,
    this.detectedUnits,
    // Legacy fields
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.weightKg,
    this.qty,
    this.itemType,
  });

  /// Get effective quantity (totalQty for new format, qty for legacy)
  int get effectiveQty => totalQty ?? qty ?? 1;

  /// Get effective item type (from items or legacy itemType)
  String get effectiveItemType {
    if (items != null && items!.isNotEmpty) {
      return items!.map((i) => i.itemType).join(', ');
    }
    return itemType ?? 'Unknown';
  }

  /// Check if this is low confidence extraction
  bool get needsReview => confidence != null && confidence! < 0.7;

  bool get isComplete =>
      lengthCm != null &&
      widthCm != null &&
      heightCm != null &&
      weightKg != null &&
      (qty != null || totalQty != null) &&
      (itemType != null || (items != null && items!.isNotEmpty));

  factory CartonData.fromJson(Map<String, dynamic> json) {
    // Parse items if present (new format)
    List<ItemData>? items;
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map((item) => ItemData.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Parse detected units if present
    DetectedUnits? detectedUnits;
    if (json['detectedUnits'] != null && json['detectedUnits'] is Map) {
      detectedUnits = DetectedUnits.fromJson(
        json['detectedUnits'] as Map<String, dynamic>,
      );
    }

    return CartonData(
      // New fields
      ctnNo: json['ctnNo'] as String?,
      items: items,
      totalQty: json['totalQty'] != null
          ? (json['totalQty'] as num).toInt()
          : null,
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : null,
      detectedUnits: detectedUnits,
      // Legacy fields
      lengthCm: json['lengthCm'] != null
          ? (json['lengthCm'] as num).toDouble()
          : null,
      widthCm: json['widthCm'] != null
          ? (json['widthCm'] as num).toDouble()
          : null,
      heightCm: json['heightCm'] != null
          ? (json['heightCm'] as num).toDouble()
          : null,
      weightKg: json['weightKg'] != null
          ? (json['weightKg'] as num).toDouble()
          : null,
      qty: json['qty'] != null ? (json['qty'] as num).toInt() : null,
      itemType: json['itemType'] as String?,
    );
  }

  Carton toCarton({required String id, required String shipmentId}) {
    return Carton(
      id: id,
      shipmentId: shipmentId,
      lengthCm: lengthCm ?? 0,
      widthCm: widthCm ?? 0,
      heightCm: heightCm ?? 0,
      weightKg: weightKg ?? 0,
      qty: effectiveQty,
      itemType: effectiveItemType,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('CartonData(');

    if (ctnNo != null) {
      buffer.write('CTN:$ctnNo, ');
    }

    buffer.write('$lengthCm×$widthCm×$heightCm cm, $weightKg kg');

    if (items != null && items!.isNotEmpty) {
      buffer.write(', items:[${items!.join(", ")}]');
    } else if (itemType != null) {
      buffer.write(', type:$itemType');
    }

    buffer.write(', qty:$effectiveQty');

    if (confidence != null) {
      buffer.write(', confidence:${(confidence! * 100).toStringAsFixed(0)}%');
    }

    buffer.write(')');
    return buffer.toString();
  }
}

/// Shipment location data extracted from voice
class ShipmentLocationData {
  final String? originCity;
  final String? destinationCity;

  const ShipmentLocationData({this.originCity, this.destinationCity});

  bool get isComplete => originCity != null && destinationCity != null;

  @override
  String toString() {
    return 'ShipmentLocationData(from: $originCity, to: $destinationCity)';
  }
}

/// Complete voice input result with location and carton data
class VoiceInputResult {
  final String? originCity;
  final String? originPostal;
  final String? originCountry;
  final String? originState;
  final String? destCity;
  final String? destPostal;
  final String? destCountry;
  final String? destState;
  final CartonData? cartonData;

  const VoiceInputResult({
    this.originCity,
    this.originPostal,
    this.originCountry,
    this.originState,
    this.destCity,
    this.destPostal,
    this.destCountry,
    this.destState,
    this.cartonData,
  });

  bool get hasLocation =>
      originCity != null &&
      originPostal != null &&
      destCity != null &&
      destPostal != null;

  bool get hasCarton => cartonData != null && cartonData!.isComplete;

  @override
  String toString() {
    return 'VoiceInputResult(from: $originCity to $destCity, carton: $cartonData)';
  }
}

/// Gemini implementation of image analyzer
class GeminiImageAnalyzer implements AiImageAnalyzer {
  final String apiKey;
  final String model;
  final Logger _logger = Logger();
  late final GenerativeModel _model;

  GeminiImageAnalyzer({
    required this.apiKey,
    this.model = 'gemini-2.0-flash-exp',
  }) {
    _model = GenerativeModel(model: model, apiKey: apiKey);
  }

  @override
  String get name => 'Gemini Vision ($model)';

  @override
  bool get isAvailable => apiKey.isNotEmpty;

  @override
  Future<List<CartonData>> extractCartonsFromImage(File imageFile) async {
    try {
      _logger.i('Analyzing packing list image with Gemini Vision');

      // Read image file
      final imageBytes = await imageFile.readAsBytes();

      // Create multimodal content
      final content = [
        Content.multi([
          TextPart(_packingListPrompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];

      // Generate with JSON mode
      final response = await _model.generateContent(
        content,
        generationConfig: GenerationConfig(
          temperature: 0.1,
          responseMimeType: 'application/json',
        ),
      );

      if (response.text == null || response.text!.isEmpty) {
        _logger.w('Gemini returned empty response');
        throw Exception('No response from Gemini');
      }

      _logger.d('Gemini response: ${response.text}');

      // Parse JSON response
      final jsonResponse = jsonDecode(response.text!);
      final cartonsList = jsonResponse is List ? jsonResponse : [];

      var cartons = cartonsList
          .map((json) => CartonData.fromJson(json as Map<String, dynamic>))
          .toList();

      // Post-process: consolidate by ctnNo if needed (fallback)
      cartons = _consolidateByCtnNo(cartons);

      _logger.i('Extracted ${cartons.length} cartons from image');

      // Log each carton for debugging
      double totalWeight = 0;
      for (int i = 0; i < cartons.length; i++) {
        final c = cartons[i];
        totalWeight += c.weightKg ?? 0;
        _logger.i(
          'Carton ${i + 1} (CTN ${c.ctnNo ?? 'N/A'}): '
          '${c.lengthCm}×${c.widthCm}×${c.heightCm}cm, '
          '${c.weightKg}kg, '
          'items: ${c.totalQty ?? c.qty ?? 0} pcs, '
          'confidence: ${c.confidence != null ? "${(c.confidence! * 100).toInt()}%" : "N/A"}',
        );
      }
      _logger.i('Total weight from AI: ${totalWeight.toStringAsFixed(1)} kg');

      // Log low-confidence extractions
      final lowConfidence = cartons.where((c) => c.needsReview).toList();
      if (lowConfidence.isNotEmpty) {
        _logger.w(
          'Found ${lowConfidence.length} cartons with low confidence that may need review',
        );
      }

      return cartons;
    } catch (e, stackTrace) {
      _logger.e(
        'Error analyzing image with Gemini',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Consolidate cartons by CTN NO as a fallback if AI doesn't group properly
  List<CartonData> _consolidateByCtnNo(List<CartonData> cartons) {
    // If no ctnNo field is present in any carton, return as-is (legacy format)
    if (cartons.every((c) => c.ctnNo == null)) {
      return cartons;
    }

    final Map<String, List<CartonData>> grouped = {};

    for (final carton in cartons) {
      final ctnNo = carton.ctnNo ?? 'UNKNOWN';
      grouped.putIfAbsent(ctnNo, () => []).add(carton);
    }

    final consolidated = <CartonData>[];

    for (final entry in grouped.entries) {
      final ctnNo = entry.key;
      final ctnCartons = entry.value;

      if (ctnCartons.length == 1) {
        // Already consolidated, use as-is
        consolidated.add(ctnCartons.first);
      } else {
        // Multiple entries for same CTN - consolidate them
        _logger.w('Consolidating ${ctnCartons.length} entries for CTN $ctnNo');

        // Use first carton as base
        final base = ctnCartons.first;

        // Collect all items
        final allItems = <ItemData>[];
        for (final c in ctnCartons) {
          if (c.items != null && c.items!.isNotEmpty) {
            allItems.addAll(c.items!);
          } else if (c.itemType != null && c.qty != null) {
            // Convert legacy format to ItemData
            allItems.add(ItemData(itemType: c.itemType!, qty: c.qty!));
          }
        }

        // Calculate total quantity
        final totalQty = allItems.fold<int>(0, (sum, item) => sum + item.qty);

        // Average confidence (or use minimum for safety)
        final confidences = ctnCartons
            .where((c) => c.confidence != null)
            .map((c) => c.confidence!)
            .toList();
        final avgConfidence = confidences.isNotEmpty
            ? confidences.reduce((a, b) => a < b ? a : b) // Use minimum
            : null;

        consolidated.add(
          CartonData(
            ctnNo: ctnNo,
            lengthCm: base.lengthCm,
            widthCm: base.widthCm,
            heightCm: base.heightCm,
            weightKg: base.weightKg,
            items: allItems,
            totalQty: totalQty,
            confidence: avgConfidence,
            detectedUnits: base.detectedUnits,
          ),
        );
      }
    }

    return consolidated;
  }

  String get _packingListPrompt => '''
You are analyzing a shipping packing list image. Extract carton data by grouping rows by CTN NO (carton number).

CRITICAL: Group by CTN NO./Carton Number FIRST, then extract data for each carton.

HEADER RECOGNITION:
Look for columns named: CTN, CTN NO, Carton No, C/N, Box No, Ctn#, CARTON NUMBER (case-insensitive)
Also look for: weight, kg, GW, gross weight, weight(kgs)
Dimensions: carton measurement, dims, dimensions, size, L×W×H, LWH
Quantity: quantity, qty, pcs, ctns
Items: style, item, description, product

GROUPING RULES:
1. Each unique CTN NO = ONE carton entry in output
2. If a CTN NO cell is blank/empty, it belongs to the PREVIOUS carton number (merged cell concept)
3. A single CTN can have multiple rows with different items - these are items in the SAME carton
4. Count unique CTN numbers, NOT table rows

FIELD PARSING:
- Dimensions: Accept formats like "61×42×42cm", "614242", "51*41*41cm", "cm 614242"
  Convert to centimeters. Preserve order as-is (don't reorder L/W/H)
- Weight: Convert to kilograms (from kg/lbs/g). This is weight of ONE carton.
  If weight is missing for some rows but present for the CTN, use that weight.
- Quantity: For multi-row cartons, extract qty per item
- Items: For multi-row cartons, collect all item types

CRITICAL - Understanding Quantities:
- Each CTN NO = ONE physical carton/box to ship
- The "quantity" column shows how many ITEMS are INSIDE that carton (e.g., 67 t-shirts inside CTN 1)
- DO NOT multiply weight by item quantity - the weight is already for the entire carton
- For shipping purposes, we're counting CARTONS, not individual items

Return ONLY valid JSON array in this format:
[
  {
    "ctnNo": "string (e.g., '1', '2', 'CTN-1')",
    "lengthCm": number,
    "widthCm": number,
    "heightCm": number,
    "weightKg": number (weight of ONE carton - DO NOT multiply by item quantity),
    "items": [
      {"itemType": "string", "qty": number (items inside this carton)}
    ],
    "totalQty": number (sum of all item quantities - this is items inside, NOT carton count),
    "confidence": number (0.0-1.0, how confident you are in this extraction),
    "detectedUnits": {"dimensions": "cm", "weight": "kg"}
  }
]

EXAMPLE 1 - Multi-row cartons:
| CTN NO | weight (kgs) | style      | quantity | carton measurement |
|--------|--------------|------------|----------|-------------------|
| 1      | 19.5         | t-shirt    | 67       | 51*41*41cm       |
| 2      | 19           | t-shirt    | 32       | 51*41*41cm       |
|        |              | t-shirt    | 34       | 51*41*41cm       | <- blank CTN = still CTN 2
| 3      | 18.5         | t-shirt    | 66       | 51*41*41cm       |
| 4      | 16.5         | hoodie     | 20       | 61*42*42cm       |

Returns exactly 4 entries (one per unique CTN NO):
[
  {"ctnNo": "1", "lengthCm": 51, "widthCm": 41, "heightCm": 41, "weightKg": 19.5, "items": [{"itemType": "t-shirt", "qty": 67}], "totalQty": 67, "confidence": 0.95, "detectedUnits": {"dimensions": "cm", "weight": "kg"}},
  {"ctnNo": "2", "lengthCm": 51, "widthCm": 41, "heightCm": 41, "weightKg": 19, "items": [{"itemType": "t-shirt", "qty": 32}, {"itemType": "t-shirt", "qty": 34}], "totalQty": 66, "confidence": 0.95, "detectedUnits": {"dimensions": "cm", "weight": "kg"}},
  {"ctnNo": "3", "lengthCm": 51, "widthCm": 41, "heightCm": 41, "weightKg": 18.5, "items": [{"itemType": "t-shirt", "qty": 66}], "totalQty": 66, "confidence": 0.95, "detectedUnits": {"dimensions": "cm", "weight": "kg"}},
  {"ctnNo": "4", "lengthCm": 61, "widthCm": 42, "heightCm": 42, "weightKg": 16.5, "items": [{"itemType": "hoodie", "qty": 20}], "totalQty": 20, "confidence": 0.95, "detectedUnits": {"dimensions": "cm", "weight": "kg"}}
]

EXAMPLE 2 - Simple single-row cartons:
| CTN | Dims (cm) | Weight | Qty | Item |
| A1  | 50×30×20  | 5 kg   | 10  | Laptops |
| A2  | 40×40×30  | 8.5 kg | 15  | Monitors |

Returns:
[
  {"ctnNo": "A1", "lengthCm": 50, "widthCm": 30, "heightCm": 20, "weightKg": 5, "items": [{"itemType": "Laptops", "qty": 10}], "totalQty": 10, "confidence": 0.95, "detectedUnits": {"dimensions": "cm", "weight": "kg"}},
  {"ctnNo": "A2", "lengthCm": 40, "widthCm": 40, "heightCm": 30, "weightKg": 8.5, "items": [{"itemType": "Monitors", "qty": 15}], "totalQty": 15, "confidence": 0.95, "detectedUnits": {"dimensions": "cm", "weight": "kg"}}
]

CONFIDENCE SCORING:
- 1.0: All fields present and clear
- 0.8-0.9: Minor uncertainty (missing weight but can estimate, slightly unclear dimensions)
- 0.5-0.7: Significant uncertainty (multiple missing fields, hard to read)
- <0.5: Very uncertain (major data gaps)

If weight is missing, estimate based on similar cartons or item type, and reduce confidence to 0.7-0.8.
''';
}

/// Gemini implementation of transcriber
class GeminiTranscriber implements AiTranscriber {
  final String apiKey;

  GeminiTranscriber({required this.apiKey});

  @override
  String get name => 'Gemini Audio';

  @override
  bool get isAvailable => apiKey.isNotEmpty;

  @override
  Future<String> transcribe(File audioFile) async {
    // TODO: Implement Gemini audio transcription
    throw UnimplementedError('Gemini transcription not yet implemented');
  }

  @override
  Future<List<CartonData>> parseCartonCommands(String text) async {
    // TODO: Implement parsing logic using Gemini
    throw UnimplementedError('Carton parsing not yet implemented');
  }
}

/// Gemini implementation of cost explainer
class GeminiCostExplainer implements AiCostExplainer {
  final String apiKey;

  GeminiCostExplainer({required this.apiKey});

  @override
  String get name => 'Gemini Text';

  @override
  bool get isAvailable => apiKey.isNotEmpty;

  @override
  Future<String> explainCost({
    required double totalCost,
    required double chargeableKg,
    required String carrier,
    required String service,
    required Map<String, dynamic> breakdown,
  }) async {
    // TODO: Implement Gemini-based explanation
    // Fallback template for now
    return _generateFallbackExplanation(
      totalCost: totalCost,
      chargeableKg: chargeableKg,
      carrier: carrier,
      service: service,
      breakdown: breakdown,
    );
  }

  String _generateFallbackExplanation({
    required double totalCost,
    required double chargeableKg,
    required String carrier,
    required String service,
    required Map<String, dynamic> breakdown,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Cost Breakdown for $carrier $service:');
    buffer.writeln();
    buffer.writeln(
      'Your shipment weighs ${chargeableKg.toStringAsFixed(1)}kg (chargeable weight).',
    );

    if (breakdown.containsKey('base')) {
      buffer.writeln('• Base fee: €${breakdown['base'].toStringAsFixed(2)}');
    }
    if (breakdown.containsKey('perKg')) {
      buffer.writeln(
        '• Per-kg charge: €${breakdown['perKg'].toStringAsFixed(2)}',
      );
    }
    if (breakdown.containsKey('fuel')) {
      buffer.writeln(
        '• Fuel surcharge: €${breakdown['fuel'].toStringAsFixed(2)}',
      );
    }
    if (breakdown.containsKey('oversize') && breakdown['oversize'] > 0) {
      buffer.writeln(
        '• Oversize fee: €${breakdown['oversize'].toStringAsFixed(2)}',
      );
    }

    buffer.writeln();
    buffer.writeln('Total: €${totalCost.toStringAsFixed(2)}');

    return buffer.toString();
  }
}

/// Factory for creating AI providers
class AiProviderFactory {
  static AiImageAnalyzer createImageAnalyzer({
    required String provider,
    required String apiKey,
  }) {
    switch (provider.toLowerCase()) {
      case 'gemini':
        return GeminiImageAnalyzer(apiKey: apiKey);
      // Add more providers here (OpenAI, Ollama, etc.)
      default:
        throw UnsupportedError('Unsupported AI provider: $provider');
    }
  }

  static AiTranscriber createTranscriber({
    required String provider,
    required String apiKey,
  }) {
    switch (provider.toLowerCase()) {
      case 'gemini':
        return GeminiTranscriber(apiKey: apiKey);
      default:
        throw UnsupportedError('Unsupported AI provider: $provider');
    }
  }

  static AiCostExplainer createCostExplainer({
    required String provider,
    required String apiKey,
  }) {
    switch (provider.toLowerCase()) {
      case 'gemini':
        return GeminiCostExplainer(apiKey: apiKey);
      default:
        throw UnsupportedError('Unsupported AI provider: $provider');
    }
  }
}
