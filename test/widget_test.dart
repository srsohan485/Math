import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mathsolving/main.dart';

void main() {
  setUpAll(() async {
    await GetStorage.init();
  });

  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(initialLocale: 'en'));
    await tester.pump();

    // App should render something on screen
    expect(find.byType(MaterialApp), findsNothing); // GetMaterialApp is used
    expect(find.byType(Scaffold), findsOneWidget);
  });
}