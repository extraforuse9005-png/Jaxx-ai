import 'package:flutter_test/flutter_test.dart';
import 'package:jaxx_ai/app/jaxx_app.dart';

void main() {
  testWidgets('Home screen shows the JAXX greeting', (tester) async {
    await tester.pumpWidget(const JaxxApp());

    expect(find.text("Hey bhai, I'm JAXX."), findsOneWidget);
    expect(find.text('Talk to JAXX'), findsOneWidget);
  });
}
