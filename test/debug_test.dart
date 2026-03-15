import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/main.dart';
import 'package:money_manager/services/user_service.dart';
import 'package:money_manager/screens/intro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Debug Skip', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await UserService.instance.clearUserData();
    await tester.pumpWidget(const MoneyManagerApp());
    await tester.pumpAndSettle();
    
    // Tap Skip
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
  });
}
