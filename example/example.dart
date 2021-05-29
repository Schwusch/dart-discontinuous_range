import 'dart:math';
import 'package:discontinuous_range/discontinuous_range.dart';

void main() {
  final allNums = DRange(1, 100); //[ 1-100 ]
  final badNums = DRange(13)
    ..add(DRange(8))
    ..add(DRange(60, 80)); //[8, 13, 60-80]
  final goodNums = allNums.clone()..subtract(badNums);
  print(goodNums.toString()); //[ 1-7, 9-12, 14-59, 81-100 ]
  final randomGoodNum =
      goodNums.index((Random().nextDouble() * goodNums.length).floor());
  print(randomGoodNum); // e.g. 58
}
