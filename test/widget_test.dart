import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Import 'package:easypatterns/main.dart' jest poprawny, ponieważ 'easypatterns'
// to nazwa Twojego pakietu zdefiniowana w pliku pubspec.yaml.
import 'package:easypatterns/main.dart';

void main() {
  testWidgets('Renders main screen and finds the library title', (WidgetTester tester) async {
    // Budujemy aplikację. Ponieważ CroftyApp używa Riverpod (jest ConsumerWidget),
    // musimy opakować ją w ProviderScope.
    await tester.pumpWidget(const ProviderScope(child: CroftyApp()));

    // Pierwszym ekranem jest Biblioteka (LibraryScreen).
    // Sprawdzamy, czy jej tytuł jest widoczny w AppBar.
    expect(find.text('Moje Wzory'), findsOneWidget);

    // Dodatkowo sprawdzamy, czy etykieta z paska nawigacji jest widoczna.
    expect(find.text('Biblioteka'), findsOneWidget);
  });
}
