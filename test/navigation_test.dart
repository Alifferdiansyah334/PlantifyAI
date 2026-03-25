import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantify/main.dart';
import 'package:plantify/screens/article_detail_screen.dart';

void main() {
  testWidgets('Navigation smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PlantifyApp());

    // Verify that we are on the dashboard

    await tester.tap(find.byIcon(Icons.menu_book_rounded));
    await tester.pumpAndSettle();

    // Verify we are on Library Screen (check for title)
    expect(find.text('Knowledge Base'), findsOneWidget);

    // Find the featured article text (from default data in LibraryScreen)
    // "The Future of Sustainable Farming: AI & Drones"
    // Since it might be truncated or split, let's look for "Sustainable Farming" or "FEATURED"
    expect(find.text('FEATURED'), findsOneWidget);

    // Tap on the Featured Article
    await tester.tap(find.text('FEATURED'));
    await tester.pumpAndSettle();

    // Verify we are on ArticleDetailScreen
    expect(find.byType(ArticleDetailScreen), findsOneWidget);
    
    // Verify content on detail screen
    expect(find.text('Key Takeaway'), findsOneWidget);
    
    // Go back
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    
    // Verify we are back on Library Screen
    expect(find.text('Knowledge Base'), findsOneWidget);
  });
}
