import 'package:flutter_test/flutter_test.dart';
import 'package:personal_budget/core/constants/app_constants.dart';

void main() {
  test('app title constant is defined', () {
    expect(AppConstants.appTitle, isNotEmpty);
  });
}
