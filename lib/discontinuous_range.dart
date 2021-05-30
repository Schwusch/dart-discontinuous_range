import 'dart:math';

class SubRange {
  final int low;
  final int high;
  final int length;

  const SubRange(this.low, this.high) : length = 1 + high - low;

  bool overlaps(SubRange range) => range.low <= high && low <= range.high;

  bool touches(SubRange range) =>
      range.low <= high + 1 && low - 1 <= range.high;

  bool covers(SubRange range) => low <= range.low && range.high <= high;

  bool isInside(SubRange range) => range.low < low && high < range.high;

  bool isBefore(SubRange range) => high < range.low;

  /// Returns inclusive combination of SubRanges as a SubRange.
  SubRange add(SubRange range) =>
      SubRange(min(low, range.low), max(high, range.high));

  /// Returns subtraction of SubRanges as an array of SubRanges.
  /// (There's a case where subtraction divides it in 2)
  List<SubRange> subtract(SubRange range) {
    if (range.covers(this)) {
      return [];
    } else if (range.isInside(this)) {
      return [
        SubRange(low, range.low - 1),
        SubRange(range.high + 1, high),
      ];
    } else if (range.low <= low) {
      return [SubRange(range.high + 1, high)];
    } else {
      return [SubRange(low, range.low - 1)];
    }
  }

  @override
  String toString() => low == high ? '$low' : '$low-$high';

  @override
  bool operator ==(Object other) =>
      other is SubRange && other.low == low && other.high == high;

  @override
  int get hashCode => low.hashCode ^ high.hashCode;
}

class DRange {
  List<SubRange> _ranges = [];
  int length = 0;

  DRange.fromDRange(DRange range) {
    range._ranges.forEach(_add);
  }

  DRange([int? a, int? b]) {
    if (a != null) {
      _add(SubRange(a, b ?? a));
    }
  }

  void _update_length() {
    length = _ranges.fold<int>(0, (int previous, SubRange range) {
      return previous + range.length;
    });
  }

  void _add(SubRange subrange) {
    var i = 0;
    while (i < _ranges.length &&
        !subrange.touches(_ranges[i]) &&
        _ranges[i].isBefore(subrange)) {
      i++;
    }
    final newRanges = _ranges.sublist(0, i);
    while (i < _ranges.length && subrange.touches(_ranges[i])) {
      subrange = subrange.add(_ranges[i]);
      i++;
    }
    newRanges.add(subrange);
    _ranges = [...newRanges, ..._ranges.sublist(i)];
    _update_length();
  }

  void _subtract(SubRange subrange) {
    var i = 0;
    while (i < _ranges.length && !subrange.overlaps(_ranges[i])) {
      i++;
    }
    var newRanges = _ranges.sublist(0, i);
    while (i < _ranges.length && subrange.overlaps(_ranges[i])) {
      newRanges = [...newRanges, ..._ranges[i].subtract(subrange)];
      i++;
    }
    _ranges = [...newRanges, ..._ranges.sublist(i)];
    _update_length();
  }

  void add(DRange range) => range._ranges.forEach(_add);

  void subtract(DRange range) => range._ranges.forEach(_subtract);

  void intersect(DRange range) {
    var newRanges = <SubRange>[];

    void _intersect(SubRange subrange) {
      var i = 0;
      while (i < _ranges.length && !subrange.overlaps(_ranges[i])) {
        i++;
      }
      while (i < _ranges.length && subrange.overlaps(_ranges[i])) {
        var low = max(_ranges[i].low, subrange.low);
        var high = min(_ranges[i].high, subrange.high);
        newRanges.add(SubRange(low, high));
        i++;
      }
    }

    range._ranges.forEach(_intersect);
    _ranges = newRanges;
    _update_length();
  }

  int index(int index) {
    var i = 0;
    while (i < _ranges.length && _ranges[i].length <= index) {
      index -= _ranges[i].length;
      i++;
    }
    return _ranges[i].low + index;
  }

  @override
  String toString() => '[ ' + _ranges.join(', ') + ' ]';

  DRange clone() => DRange.fromDRange(this);

  List<int> numbers() => _ranges.fold([], (result, subrange) {
        var i = subrange.low;
        while (i <= subrange.high) {
          result.add(i);
          i++;
        }
        return result;
      });

  List<SubRange> get subranges => [..._ranges];
}
