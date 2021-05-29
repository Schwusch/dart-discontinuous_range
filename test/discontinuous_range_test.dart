import 'package:discontinuous_range/discontinuous_range.dart';
import 'package:test/test.dart';

void main() {
  group('empty drange', () {
    test('should initialize with no subranges', () {
      expect(DRange().toString(), equals('[  ]'));
    });
  });

  group('add sets', () {
    test('should allow adding numbers', () {
      final drange = DRange(5);
      expect(drange.toString(), equals('[ 5 ]'));
      drange.add(DRange(6));
      expect(drange.toString(), equals('[ 5-6 ]'));
      drange.add(DRange(8));
      expect(drange.toString(), equals('[ 5-6, 8 ]'));
      drange.add(DRange(7));
      expect(drange.toString(), equals('[ 5-8 ]'));
      expect(drange.length, equals(4));
    });

    test('should allow adding ranges of numbers', () {
      final drange = DRange(1, 5);
      expect(drange.toString(), equals('[ 1-5 ]'));
      drange.add(DRange(6, 10));
      expect(drange.toString(), equals('[ 1-10 ]'));
      drange.add(DRange(15, 20));
      expect(drange.toString(), equals('[ 1-10, 15-20 ]'));
      drange.add(DRange(0, 14));
      expect(drange.toString(), equals('[ 0-20 ]'));
      expect(drange.length, 21);
    });

    test('in the beginning of the range', () {
      final drange = DRange(10, 20);
      expect(drange.toString(), equals('[ 10-20 ]'));
      drange.add(DRange(5, 7));
      expect(drange.toString(), equals('[ 5-7, 10-20 ]'));
    });

    test('between entries in the range', () {
      final drange = DRange(10, 20);
      expect(drange.toString(), equals('[ 10-20 ]'));
      drange.add(DRange(0, 5));
      drange.add(DRange(7, 8));
      expect(drange.toString(), equals('[ 0-5, 7-8, 10-20 ]'));
    });
  });

  group('subtract sets', () {
    test('should allow subtracting numbers', () {
      final drange = DRange(1, 10);
      drange.subtract(DRange(5));
      expect(drange.toString(), equals('[ 1-4, 6-10 ]'));
      drange.subtract(DRange(7));
      expect(drange.toString(), equals('[ 1-4, 6, 8-10 ]'));
      drange.subtract(DRange(6));
      expect(drange.toString(), equals('[ 1-4, 8-10 ]'));
      expect(drange.length, equals(7));
    });

    test('should allow subtracting ranges of numbers', () {
      final drange = DRange(1, 100);
      drange.subtract(DRange(5, 15));
      expect(drange.toString(), equals('[ 1-4, 16-100 ]'));
      drange.subtract(DRange(90, 200));
      expect(drange.toString(), equals('[ 1-4, 16-89 ]'));
      expect(drange.length, equals(78));
    });

    test('should allow subtracting ranges added out of order', () {
      final drange = DRange();
      drange.add(DRange(4, 6));
      drange.add(DRange(15, 20));
      drange.add(DRange(8, 12));
      drange.subtract(DRange(5, 10));
      expect(drange.toString(), equals('[ 4, 11-12, 15-20 ]'));
    });
  });

  group('intersect sets', () {
    test('should allow intersecting numbers', () {
      final drange = DRange(5, 20);
      expect(drange.toString(), equals('[ 5-20 ]'));
      drange.intersect(DRange(7));
      expect(drange.toString(), equals('[ 7 ]'));
    });

    test('should allow intersecting ranges of numbers', () {
      final drange = DRange(1, 5);
      expect(drange.toString(), equals('[ 1-5 ]'));
      drange.intersect(DRange(6, 10));
      expect(drange.toString(), equals('[  ]'));
      drange.add(DRange(15, 20));
      expect(drange.toString(), equals('[ 15-20 ]'));
      drange.intersect(DRange(0, 18));
      expect(drange.toString(), equals('[ 15-18 ]'));
      expect(drange.length, equals(4));
    });
  });

  group('index sets', () {
    test('should appropriately retrieve numbers in range by index', () {
      final drange = DRange(0, 9);
      drange.add(DRange(20, 29));
      drange.add(DRange(40, 49));
      expect(drange.index(5), equals(5));
      expect(drange.index(15), equals(25));
      expect(drange.index(25), equals(45));
      expect(drange.length, equals(30));
    });
  });

  group('clone sets', () {
    test('should be able to clone a DRange that doesn\'t affect the original',
        () {
      final drange = DRange(0, 9);
      final erange = drange.clone();
      erange.subtract(DRange(5));
      expect(drange.toString(), equals('[ 0-9 ]'));
      expect(erange.toString(), equals('[ 0-4, 6-9 ]'));
    });
  });

  group('accessing numbers', () {
    test('should be able to get contained numbers', () {
      final drange = DRange(1, 4);
      drange.subtract(DRange(2));
      drange.add(DRange(6));
      final numbers = drange.numbers();
      expect(numbers, equals([1, 3, 4, 6]));
      drange.subtract(DRange(3));
      expect(numbers, equals([1, 3, 4, 6]));
    });
  });

  group('accessing subranges', () {
    test('should be able to get copy of subranges', () {
      final drange = DRange(1, 4);
      drange.add(DRange(6, 8));
      final subranges = drange.subranges;
      const expected = [SubRange(1, 4), SubRange(6, 8)];
      expect(subranges, expected);
      drange.subtract(DRange(6, 8));
      expect(subranges, expected);
    });
  });
}
