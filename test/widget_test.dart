import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/main.dart';

void main() {
  testWidgets('Informin opens its latest-news experience', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: InforminApp()));
    expect(find.text('Latest news'), findsOneWidget);
    expect(find.text('informin'), findsOneWidget);
  });
}
