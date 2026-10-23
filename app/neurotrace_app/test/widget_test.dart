import 'package:flutter_test/flutter_test.dart';
import 'package:neurotrace/models/headache_type.dart';

void main() {
  test('label key maps to headache types', () {
    expect(HeadacheType.fromLabel(0), HeadacheType.normal);
    expect(HeadacheType.fromLabel(2), HeadacheType.stress);
    expect(HeadacheType.fromLabel(6), HeadacheType.cluster);
  });
}
