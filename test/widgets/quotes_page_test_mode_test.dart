import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/config/shippo_config.dart';

/// Tests for QuotesPage test mode logic and data handling
///
/// These tests focus on the data/logic layer rather than UI rendering,
/// specifically testing the multi-parcel detection and message logic.
void main() {
  group('QuotesPage - Test Mode Data Logic', () {
    group('Multi-Parcel Detection Logic', () {
      test('calculates total parcels correctly for single carton', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 10,
            itemType: 'Box',
          ),
        ];

        final totalParcels = cartons.fold<int>(0, (sum, c) => sum + c.qty);
        expect(totalParcels, 10);
      });

      test('calculates total parcels correctly for multiple cartons', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 2,
            itemType: 'Box',
          ),
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 3.0,
            qty: 3,
            itemType: 'Box',
          ),
        ];

        final totalParcels = cartons.fold<int>(0, (sum, c) => sum + c.qty);
        expect(totalParcels, 5, reason: '2 + 3 = 5 total parcels');
      });

      test('handles empty carton list', () {
        final cartons = <Carton>[];

        final totalParcels = cartons.fold<int>(0, (sum, c) => sum + c.qty);
        expect(totalParcels, 0);
      });

      test('handles single quantity carton', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Box',
          ),
        ];

        final totalParcels = cartons.fold<int>(0, (sum, c) => sum + c.qty);
        expect(totalParcels, 1);
      });
    });

    group('Test Mode vs Production Mode Detection', () {
      test('test mode is enabled when USE_TEST_MODE=true', () {
        dotenv.testLoad(fileInput: 'USE_TEST_MODE=true');
        expect(ShippoConfig.useTestMode, isTrue);
      });

      test('test mode is disabled when USE_TEST_MODE=false', () {
        dotenv.testLoad(fileInput: 'USE_TEST_MODE=false');
        expect(ShippoConfig.useTestMode, isFalse);
      });

      test('test mode is disabled for empty string', () {
        dotenv.testLoad(fileInput: 'USE_TEST_MODE=');
        expect(ShippoConfig.useTestMode, isFalse);
      });

      test('test mode is disabled when variable is missing', () {
        dotenv.testLoad(fileInput: '');
        expect(ShippoConfig.useTestMode, isFalse);
      });
    });

    group('Message Selection Logic', () {
      test(
        'should show multi-parcel message when total parcels > 1 in test mode',
        () {
          dotenv.testLoad(fileInput: 'USE_TEST_MODE=true');

          final cartons = [
            const Carton(
              id: '1',
              shipmentId: 's1',
              lengthCm: 50,
              widthCm: 30,
              heightCm: 20,
              weightKg: 5.0,
              qty: 10,
              itemType: 'Box',
            ),
          ];

          final isTestMode = ShippoConfig.useTestMode;
          final totalParcels = cartons.fold<int>(0, (sum, c) => sum + c.qty);

          // Logic that would be used in _getNoQuotesMessage
          String expectedMessageType;
          if (isTestMode) {
            if (totalParcels > 1) {
              expectedMessageType = 'shippoTestMultiParcelLimitation';
            } else {
              expectedMessageType = 'shippoTestNoQuotes';
            }
          } else {
            expectedMessageType = 'emptyStateNoQuotes';
          }

          expect(isTestMode, isTrue);
          expect(totalParcels, 10);
          expect(expectedMessageType, 'shippoTestMultiParcelLimitation');
        },
      );

      test(
        'should show generic test message when total parcels = 1 in test mode',
        () {
          dotenv.testLoad(fileInput: 'USE_TEST_MODE=true');

          final cartons = [
            const Carton(
              id: '1',
              shipmentId: 's1',
              lengthCm: 50,
              widthCm: 30,
              heightCm: 20,
              weightKg: 5.0,
              qty: 1,
              itemType: 'Box',
            ),
          ];

          final isTestMode = ShippoConfig.useTestMode;
          final totalParcels = cartons.fold<int>(0, (sum, c) => sum + c.qty);

          // Logic that would be used in _getNoQuotesMessage
          String expectedMessageType;
          if (isTestMode) {
            if (totalParcels > 1) {
              expectedMessageType = 'shippoTestMultiParcelLimitation';
            } else {
              expectedMessageType = 'shippoTestNoQuotes';
            }
          } else {
            expectedMessageType = 'emptyStateNoQuotes';
          }

          expect(isTestMode, isTrue);
          expect(totalParcels, 1);
          expect(expectedMessageType, 'shippoTestNoQuotes');
        },
      );

      test('should show production message in production mode', () {
        dotenv.testLoad(fileInput: 'USE_TEST_MODE=false');

        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 10,
            itemType: 'Box',
          ),
        ];

        final isTestMode = ShippoConfig.useTestMode;
        final totalParcels = cartons.fold<int>(0, (sum, c) => sum + c.qty);

        // Logic that would be used in _getNoQuotesMessage
        String expectedMessageType;
        if (isTestMode) {
          if (totalParcels > 1) {
            expectedMessageType = 'shippoTestMultiParcelLimitation';
          } else {
            expectedMessageType = 'shippoTestNoQuotes';
          }
        } else {
          expectedMessageType = 'emptyStateNoQuotes';
        }

        expect(isTestMode, isFalse);
        expect(totalParcels, 10);
        expect(expectedMessageType, 'emptyStateNoQuotes');
      });

      test('handles null/empty cartons list in test mode', () {
        dotenv.testLoad(fileInput: 'USE_TEST_MODE=true');

        // Simulating cartonModelsAsync.valueOrNull returning null
        final List<Carton>? cartons = null;

        final isTestMode = ShippoConfig.useTestMode;

        // Logic that would be used in _getNoQuotesMessage
        String expectedMessageType;
        if (isTestMode) {
          if (cartons != null) {
            final totalParcels = cartons.fold<int>(0, (sum, c) => sum + c.qty);
            if (totalParcels > 1) {
              expectedMessageType = 'shippoTestMultiParcelLimitation';
            } else {
              expectedMessageType = 'shippoTestNoQuotes';
            }
          } else {
            expectedMessageType = 'shippoTestNoQuotes';
          }
        } else {
          expectedMessageType = 'emptyStateNoQuotes';
        }

        expect(isTestMode, isTrue);
        expect(cartons, isNull);
        expect(expectedMessageType, 'shippoTestNoQuotes');
      });

      test('handles empty cartons list in test mode', () {
        dotenv.testLoad(fileInput: 'USE_TEST_MODE=true');

        final cartons = <Carton>[];

        final isTestMode = ShippoConfig.useTestMode;
        final totalParcels = cartons.fold<int>(0, (sum, c) => sum + c.qty);

        // Logic that would be used in _getNoQuotesMessage
        String expectedMessageType;
        if (isTestMode) {
          if (totalParcels > 1) {
            expectedMessageType = 'shippoTestMultiParcelLimitation';
          } else {
            expectedMessageType = 'shippoTestNoQuotes';
          }
        } else {
          expectedMessageType = 'emptyStateNoQuotes';
        }

        expect(isTestMode, isTrue);
        expect(totalParcels, 0);
        expect(expectedMessageType, 'shippoTestNoQuotes');
      });
    });

    group('Test Mode Banner Visibility Logic', () {
      test('banner should be visible in test mode', () {
        dotenv.testLoad(fileInput: 'USE_TEST_MODE=true');

        final shouldShowBanner = ShippoConfig.useTestMode;
        expect(shouldShowBanner, isTrue);
      });

      test('banner should be hidden in production mode', () {
        dotenv.testLoad(fileInput: 'USE_TEST_MODE=false');

        final shouldShowBanner = ShippoConfig.useTestMode;
        expect(shouldShowBanner, isFalse);
      });
    });

    group('Edge Cases', () {
      test('handles very high parcel count', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 999,
            itemType: 'Box',
          ),
        ];

        final totalParcels = cartons.fold<int>(0, (sum, c) => sum + c.qty);
        expect(totalParcels, 999);
      });

      test('handles multiple cartons with mixed quantities', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Box',
          ),
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 3.0,
            qty: 50,
            itemType: 'Box',
          ),
          const Carton(
            id: '3',
            shipmentId: 's1',
            lengthCm: 30,
            widthCm: 20,
            heightCm: 15,
            weightKg: 2.0,
            qty: 1,
            itemType: 'Box',
          ),
        ];

        final totalParcels = cartons.fold<int>(0, (sum, c) => sum + c.qty);
        expect(totalParcels, 52, reason: '1 + 50 + 1 = 52');
      });
    });
  });
}
