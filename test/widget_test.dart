import 'package:flutter_test/flutter_test.dart';
import 'package:auction_hub/main.dart';

void main() {
  testWidgets('AuctionHub app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AuctionHubApp());
    expect(find.byType(AuctionHubApp), findsOneWidget);
  });
}
