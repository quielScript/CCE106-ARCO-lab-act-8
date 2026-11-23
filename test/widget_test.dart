import 'package:flutter_test/flutter_test.dart';
import 'package:intergrated_flutter_student_application/main.dart';

void main() {
  testWidgets('App starts on login screen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });
}
