import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaxx_ai/app/jaxx_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (_) async => null);
  });

  testWidgets('Home screen shows the JAXX greeting', (tester) async {
    await tester.pumpWidget(const JaxxApp());
    await tester.pump();

    expect(find.text("Hey bhai, I'm JAXX."), findsOneWidget);
  });
}
