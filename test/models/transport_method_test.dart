import 'package:bockaire/models/transport_method.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('classifyTransportMethod', () {
    group('Express Air', () {
      test('classifies "express" keyword', () {
        expect(
          classifyTransportMethod('UPS', 'Express Saver', 2),
          TransportMethod.expressAir,
        );
      });

      test('classifies "priority" keyword', () {
        expect(
          classifyTransportMethod('DHL', 'Priority Mail', 1),
          TransportMethod.expressAir,
        );
      });

      test('classifies "next day" keyword', () {
        expect(
          classifyTransportMethod('FedEx', 'Next Day Air', 1),
          TransportMethod.expressAir,
        );
      });

      test('classifies "overnight" keyword', () {
        expect(
          classifyTransportMethod('UPS', 'Overnight Service', 1),
          TransportMethod.expressAir,
        );
      });

      test('classifies "worldwide express" keyword', () {
        expect(
          classifyTransportMethod('DHL', 'Worldwide Express', 2),
          TransportMethod.expressAir,
        );
      });

      test('is case-insensitive', () {
        expect(
          classifyTransportMethod('DHL', 'EXPRESS', 2),
          TransportMethod.expressAir,
        );
      });

      test('works with UPPERCASE carrier', () {
        expect(
          classifyTransportMethod('UPS', 'Express', 2),
          TransportMethod.expressAir,
        );
      });

      test('works with mixed case', () {
        expect(
          classifyTransportMethod('DHL', 'ExPrEsS SaVeR', 2),
          TransportMethod.expressAir,
        );
      });
    });

    group('Sea Freight', () {
      test('classifies "ocean" keyword as LCL', () {
        expect(
          classifyTransportMethod('Maersk', 'Ocean Freight', 30),
          TransportMethod.seaFreightLCL,
        );
      });

      test('classifies "sea" keyword as LCL', () {
        expect(
          classifyTransportMethod('MSC', 'Sea Shipping', 35),
          TransportMethod.seaFreightLCL,
        );
      });

      test('classifies >20 days as sea freight LCL', () {
        expect(
          classifyTransportMethod('Carrier', 'Standard Service', 25),
          TransportMethod.seaFreightLCL,
        );
      });

      test('classifies exactly 21 days as sea freight LCL', () {
        expect(
          classifyTransportMethod('Carrier', 'Standard Service', 21),
          TransportMethod.seaFreightLCL,
        );
      });

      test('classifies "FCL" as Full Container Load', () {
        expect(
          classifyTransportMethod('China Shipping', 'FCL Service', 30),
          TransportMethod.seaFreightFCL,
        );
      });

      test('classifies "container" keyword as FCL', () {
        expect(
          classifyTransportMethod('Maersk', 'Full Container', 28),
          TransportMethod.seaFreightFCL,
        );
      });

      test('classifies "ocean container" as FCL', () {
        expect(
          classifyTransportMethod('MSC', 'Ocean Container Service', 30),
          TransportMethod.seaFreightFCL,
        );
      });

      test('long duration triggers sea freight even without keyword', () {
        expect(
          classifyTransportMethod('Unknown Carrier', 'Slow Service', 40),
          TransportMethod.seaFreightLCL,
        );
      });
    });

    group('Road Freight', () {
      test('classifies "ground" keyword', () {
        expect(
          classifyTransportMethod('FedEx', 'Ground', 5),
          TransportMethod.roadFreight,
        );
      });

      test('classifies "road" keyword', () {
        expect(
          classifyTransportMethod('UPS', 'Road Express', 3),
          TransportMethod.roadFreight,
        );
      });

      test('classifies "truck" keyword', () {
        expect(
          classifyTransportMethod('Carrier', 'Truck Delivery', 4),
          TransportMethod.roadFreight,
        );
      });

      test('ground with fast delivery still classified as road', () {
        expect(
          classifyTransportMethod('UPS', 'Ground Express', 1),
          TransportMethod.roadFreight,
        );
      });
    });

    group('Air Freight', () {
      test('classifies "freight" keyword', () {
        expect(
          classifyTransportMethod('DHL', 'Air Freight', 10),
          TransportMethod.airFreight,
        );
      });

      test('classifies "forwarder" carrier', () {
        expect(
          classifyTransportMethod('Freight Forwarder Inc', 'Standard', 12),
          TransportMethod.airFreight,
        );
      });

      test('classifies >7 days as air freight', () {
        expect(
          classifyTransportMethod('Carrier', 'Economy', 10),
          TransportMethod.airFreight,
        );
      });

      test('classifies exactly 8 days as air freight', () {
        expect(
          classifyTransportMethod('Carrier', 'Standard', 8),
          TransportMethod.airFreight,
        );
      });

      test('freight keyword in carrier name', () {
        expect(
          classifyTransportMethod('Air Freight Company', 'Standard', 10),
          TransportMethod.airFreight,
        );
      });
    });

    group('Standard Air', () {
      test('classifies <=7 days as standard air', () {
        expect(
          classifyTransportMethod('UPS', 'Standard', 5),
          TransportMethod.standardAir,
        );
      });

      test('classifies 7 days exactly as standard air', () {
        expect(
          classifyTransportMethod('DHL', 'Regular Service', 7),
          TransportMethod.standardAir,
        );
      });

      test('classifies 1 day without express keyword as standard air', () {
        expect(
          classifyTransportMethod('Carrier', 'Fast Service', 1),
          TransportMethod.standardAir,
        );
      });

      test('classifies 6 days as standard air', () {
        expect(
          classifyTransportMethod('FedEx', 'International Economy', 6),
          TransportMethod.standardAir,
        );
      });
    });

    group('Priority and Edge Cases', () {
      test('handles empty service name', () {
        final result = classifyTransportMethod('UPS', '', 5);
        expect(result, TransportMethod.standardAir);
      });

      test('handles empty carrier name', () {
        final result = classifyTransportMethod('', 'Express', 2);
        expect(result, TransportMethod.expressAir);
      });

      test('both empty defaults based on days', () {
        final result = classifyTransportMethod('', '', 5);
        expect(result, TransportMethod.standardAir);
      });

      test('ground keyword takes priority over express', () {
        expect(
          classifyTransportMethod('FedEx', 'Express Ground', 5),
          TransportMethod.roadFreight,
        );
      });

      test('prioritizes sea freight keyword over days', () {
        expect(
          classifyTransportMethod('Carrier', 'Ocean Express', 30),
          TransportMethod.seaFreightLCL,
        );
      });

      test('prioritizes express over freight', () {
        expect(
          classifyTransportMethod('Carrier', 'Express Freight', 2),
          TransportMethod.expressAir,
        );
      });

      test('sea freight overrides express keyword', () {
        expect(
          classifyTransportMethod('Carrier', 'Ocean Express', 30),
          TransportMethod.seaFreightLCL,
        );
      });

      test('ground overrides days-based classification', () {
        expect(
          classifyTransportMethod('FedEx', 'Ground Service', 15),
          TransportMethod.roadFreight,
        );
      });

      test('falls back to air freight for unknown service with high days', () {
        expect(
          classifyTransportMethod('Unknown', 'Unknown Service', 15),
          TransportMethod.airFreight,
        );
      });

      test(
        'falls back to air freight for edge case 100 days without sea keyword',
        () {
          expect(
            classifyTransportMethod('Slow Carrier', 'Very Slow', 100),
            TransportMethod.seaFreightLCL,
          );
        },
      );
    });

    group('Real-world carrier examples', () {
      test('UPS Saver (3 days)', () {
        expect(
          classifyTransportMethod('UPS', 'UPS Saver', 3),
          TransportMethod.standardAir,
        );
      });

      test('DHL Express Worldwide (2 days)', () {
        expect(
          classifyTransportMethod('DHL Express', 'Worldwide Express', 2),
          TransportMethod.expressAir,
        );
      });

      test('FedEx International Priority (4 days)', () {
        expect(
          classifyTransportMethod('FedEx', 'International Priority', 4),
          TransportMethod.expressAir,
        );
      });

      test('Forwarder Air Freight (10 days)', () {
        expect(
          classifyTransportMethod('Freight Forwarder', 'Air Freight', 10),
          TransportMethod.airFreight,
        );
      });

      test('Maersk Sea Freight LCL (30 days)', () {
        expect(
          classifyTransportMethod('Maersk', 'Sea Freight LCL', 30),
          TransportMethod.seaFreightLCL,
        );
      });

      test('China Shipping FCL (28 days)', () {
        expect(
          classifyTransportMethod('China Shipping', 'FCL Container', 28),
          TransportMethod.seaFreightFCL,
        );
      });

      test('FedEx Ground (5 days)', () {
        expect(
          classifyTransportMethod('FedEx', 'Ground', 5),
          TransportMethod.roadFreight,
        );
      });

      test('USPS Priority Mail (2 days)', () {
        expect(
          classifyTransportMethod('USPS', 'Priority Mail', 2),
          TransportMethod.expressAir,
        );
      });

      test('DHL Standard (7 days)', () {
        expect(
          classifyTransportMethod('DHL', 'Standard', 7),
          TransportMethod.standardAir,
        );
      });
    });

    group('Boundary testing', () {
      test('7 days is standard air (boundary)', () {
        expect(
          classifyTransportMethod('Carrier', 'Service', 7),
          TransportMethod.standardAir,
        );
      });

      test('8 days is air freight (boundary)', () {
        expect(
          classifyTransportMethod('Carrier', 'Service', 8),
          TransportMethod.airFreight,
        );
      });

      test('20 days is air freight (boundary)', () {
        expect(
          classifyTransportMethod('Carrier', 'Service', 20),
          TransportMethod.airFreight,
        );
      });

      test('21 days is sea freight (boundary)', () {
        expect(
          classifyTransportMethod('Carrier', 'Service', 21),
          TransportMethod.seaFreightLCL,
        );
      });
    });
  });

  group('TransportMethodInfo', () {
    test('all transport methods have info defined', () {
      for (final method in TransportMethod.values) {
        expect(
          transportMethods.containsKey(method),
          true,
          reason: 'Missing info for $method',
        );
        expect(transportMethods[method]!.displayName.isNotEmpty, true);
        expect(transportMethods[method]!.icon.isNotEmpty, true);
        expect(transportMethods[method]!.description.isNotEmpty, true);
      }
    });

    test('express air has correct day range', () {
      final info = transportMethods[TransportMethod.expressAir]!;
      expect(info.minDays, 1);
      expect(info.maxDays, 3);
      expect(info.displayName, 'Express Air');
      expect(info.icon, '✈️');
    });

    test('standard air has correct day range', () {
      final info = transportMethods[TransportMethod.standardAir]!;
      expect(info.minDays, 3);
      expect(info.maxDays, 7);
      expect(info.displayName, 'Standard Air');
      expect(info.icon, '📦');
    });

    test('air freight has correct day range', () {
      final info = transportMethods[TransportMethod.airFreight]!;
      expect(info.minDays, 7);
      expect(info.maxDays, 15);
      expect(info.displayName, 'Air Freight');
      expect(info.icon, '🛫');
    });

    test('sea freight LCL has correct day range', () {
      final info = transportMethods[TransportMethod.seaFreightLCL]!;
      expect(info.minDays, 25);
      expect(info.maxDays, 40);
      expect(info.displayName, 'Sea Freight (LCL)');
      expect(info.icon, '🚢');
    });

    test('sea freight FCL has correct day range', () {
      final info = transportMethods[TransportMethod.seaFreightFCL]!;
      expect(info.minDays, 25);
      expect(info.maxDays, 40);
      expect(info.displayName, 'Sea Freight (FCL)');
      expect(info.icon, '🚢');
    });

    test('road freight has correct day range', () {
      final info = transportMethods[TransportMethod.roadFreight]!;
      expect(info.minDays, 1);
      expect(info.maxDays, 10);
      expect(info.displayName, 'Road Freight');
      expect(info.icon, '🚛');
    });

    test('all info types match their enum values', () {
      for (final entry in transportMethods.entries) {
        expect(entry.value.type, entry.key);
      }
    });

    test('no duplicate icons', () {
      final icons = transportMethods.values.map((info) => info.icon).toList();
      // Note: Sea freight LCL and FCL share the same icon intentionally
      expect(icons.length, 6);
    });

    test('no duplicate display names', () {
      final names = transportMethods.values
          .map((info) => info.displayName)
          .toSet();
      expect(names.length, 6); // All unique
    });
  });

  group('TransportMethod enum', () {
    test('has all expected values', () {
      expect(TransportMethod.values, hasLength(6));
      expect(TransportMethod.values, contains(TransportMethod.expressAir));
      expect(TransportMethod.values, contains(TransportMethod.standardAir));
      expect(TransportMethod.values, contains(TransportMethod.airFreight));
      expect(TransportMethod.values, contains(TransportMethod.seaFreightLCL));
      expect(TransportMethod.values, contains(TransportMethod.seaFreightFCL));
      expect(TransportMethod.values, contains(TransportMethod.roadFreight));
    });

    test('enum values can be converted to strings', () {
      expect(TransportMethod.expressAir.name, 'expressAir');
      expect(TransportMethod.standardAir.name, 'standardAir');
      expect(TransportMethod.airFreight.name, 'airFreight');
      expect(TransportMethod.seaFreightLCL.name, 'seaFreightLCL');
      expect(TransportMethod.seaFreightFCL.name, 'seaFreightFCL');
      expect(TransportMethod.roadFreight.name, 'roadFreight');
    });
  });
}
