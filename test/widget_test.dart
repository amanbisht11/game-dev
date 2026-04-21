import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hand_job/app.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: NumCricketApp()));
    
    // Just verify the app loads (Logo text)
    expect(find.text('NUM'), findsOneWidget);
    expect(find.text('CRICKET'), findsOneWidget);
  });
}
