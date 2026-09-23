import 'package:flutter_test/flutter_test.dart';
import 'package:project_app/main.dart';

void main() {
  testWidgets('login screen opens group members page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('บันทึกบุญ'), findsOneWidget);
    expect(find.text('ชื่อผู้ใช้'), findsOneWidget);

    await tester.tap(find.text('สมาชิกกลุ่ม'));
    await tester.pumpAndSettle();

    expect(find.text('สมาชิกกลุ่ม'), findsOneWidget);
    expect(find.text('นายปภังกร ผาทอง'), findsOneWidget);
    expect(find.textContaining('6721652323'), findsOneWidget);
    expect(find.text('นายอะครชัย ทองสุพรรณ์'), findsOneWidget);
    expect(find.textContaining('6721652846'), findsOneWidget);
  });
}
