import 'package:bockaire/utils/duration_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseDuration', () {
    group('duration_terms parsing', () {
      test('parses range format "2-3 days"', () {
        expect(parseDuration(null, '2-3 days'), (2, 3));
      });

      test('parses range with "business days"', () {
        expect(parseDuration(null, '2-3 business days'), (2, 3));
      });

      test('parses range with prefix text', () {
        expect(parseDuration(null, 'Delivery in 5-7 business days'), (5, 7));
      });

      test('parses single number "5 days"', () {
        expect(parseDuration(null, '5 days'), (5, 6));
      });

      test('parses single with "business days"', () {
        expect(parseDuration(null, '3 business days'), (3, 4));
      });

      test('parses single with "day" (singular)', () {
        expect(parseDuration(null, '1 day'), (1, 2));
      });

      test('handles same-day range "1-1 days"', () {
        expect(parseDuration(null, '1-1 days'), (1, 1));
      });

      test('parses range without spaces "2-3days"', () {
        expect(parseDuration(null, '2-3days'), (2, 3));
      });

      test('parses range with extra whitespace "  5 - 7  days  "', () {
        expect(parseDuration(null, '  5-7  days  '), (5, 7));
      });

      test('parses complex sentence with range', () {
        expect(parseDuration(null, 'Expected delivery in 3-5 business days'), (
          3,
          5,
        ));
      });
    });

    group('estimated_days fallback', () {
      test('uses estimated_days when duration_terms is null', () {
        expect(parseDuration(3, null), (3, 4));
      });

      test('uses estimated_days when duration_terms is empty', () {
        expect(parseDuration(5, ''), (5, 6));
      });

      test('uses estimated_days when duration_terms is invalid', () {
        expect(parseDuration(7, 'invalid text'), (7, 8));
      });

      test('uses estimated_days when duration_terms has no numbers', () {
        expect(parseDuration(4, 'ships soon'), (4, 5));
      });

      test('handles estimated_days of 1', () {
        expect(parseDuration(1, null), (1, 2));
      });

      test('handles large estimated_days', () {
        expect(parseDuration(30, null), (30, 31));
      });
    });

    group('edge cases', () {
      test('returns fallback when both null', () {
        expect(parseDuration(null, null), (5, 7));
      });

      test('returns fallback when estimated_days is 0', () {
        expect(parseDuration(0, null), (5, 7));
      });

      test('returns fallback when estimated_days is negative', () {
        expect(parseDuration(-1, null), (5, 7));
      });

      test('prioritizes duration_terms over estimated_days', () {
        expect(parseDuration(10, '2-3 days'), (2, 3));
      });

      test('handles duration_terms with only whitespace', () {
        expect(parseDuration(5, '   '), (5, 6));
      });

      test('handles duration_terms with special characters', () {
        expect(parseDuration(null, '2-3 days!!!'), (2, 3));
      });

      test('handles duration_terms with multiple ranges (uses first)', () {
        expect(parseDuration(null, '2-3 or 5-7 days'), (2, 3));
      });

      test('handles very large day ranges', () {
        expect(parseDuration(null, '25-40 days'), (25, 40));
      });

      test('handles reversed range (still parses correctly)', () {
        expect(parseDuration(null, '7-5 days'), (7, 5));
      });
    });

    group('real-world Shippo examples', () {
      test('USPS Priority: "1-3 business days"', () {
        expect(parseDuration(2, '1-3 business days'), (1, 3));
      });

      test('FedEx Ground: "5 business days"', () {
        expect(parseDuration(5, '5 business days'), (5, 6));
      });

      test('DHL Express with estimated_days only', () {
        expect(parseDuration(2, null), (2, 3));
      });

      test('Carrier without any ETA data (fallback)', () {
        expect(parseDuration(null, null), (5, 7));
      });

      test('Empty duration_terms with estimated_days', () {
        expect(parseDuration(3, ''), (3, 4));
      });
    });
  });
}
