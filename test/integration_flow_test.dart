import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intergrated_flutter_student_application/demo_auth.dart';
import 'package:intergrated_flutter_student_application/main.dart';

void main() {
  setUp(() {
    DemoAuth.logout();
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
  });

  testWidgets(
    'Full application flow: Login, Register, Tabs, Calculator, Social, Profile, and Logout',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const StudentApp());
      await tester.pumpAndSettle();

      // 1. Open application -> Login appears first
      expect(find.text('Login'), findsWidgets);
      expect(find.text('Welcome Back!'), findsOneWidget);

      // 2. Submit empty login fields -> Validation messages appear
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your username.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);

      // 3. Enter incorrect credentials -> Login rejected (SnackBar appears)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'wronguser',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrongpass',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid username or password.'), findsOneWidget);

      // Wait for SnackBar to dismiss
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // 4. Enter admin / admin123 -> Dashboard opens
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'admin',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'admin123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // 5. Read dashboard greeting -> Displays Welcome, admin!
      expect(find.text('Welcome, admin!'), findsOneWidget);
      expect(find.text('Dashboard'), findsWidgets);

      // 6. Open Calculator and calculate 20 and 5 (and 10 + 5)
      // Switch to Calculator tab (index 1)
      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pumpAndSettle();
      expect(find.text('BASIC CALCULATOR'), findsOneWidget);

      // Test 20 and 5
      await tester.enterText(
        find.widgetWithText(TextField, 'First Number'),
        '20',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Second Number'),
        '5',
      );

      // Addition (+) -> 25.0
      await tester.tap(find.widgetWithText(ElevatedButton, '+'));
      await tester.pumpAndSettle();
      expect(find.text('25.0'), findsOneWidget);

      // Subtraction (−) -> 15.0
      await tester.tap(find.widgetWithText(ElevatedButton, '−'));
      await tester.pumpAndSettle();
      expect(find.text('15.0'), findsOneWidget);

      // Multiplication (×) -> 100.0
      await tester.tap(find.widgetWithText(ElevatedButton, '×'));
      await tester.pumpAndSettle();
      expect(find.text('100.0'), findsOneWidget);

      // Division (÷) -> 4.0
      await tester.tap(find.widgetWithText(ElevatedButton, '÷'));
      await tester.pumpAndSettle();
      expect(find.text('4.0'), findsOneWidget);

      // Test 10 + 5 -> 15.0
      await tester.enterText(
        find.widgetWithText(TextField, 'First Number'),
        '10',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Second Number'),
        '5',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, '+'));
      await tester.pumpAndSettle();
      expect(find.text('15.0'), findsOneWidget);

      // 7. Switch tabs and return to Calculator -> Inputs and result remain
      await tester.tap(find.byType(NavigationDestination).at(0));
      await tester.pumpAndSettle();
      expect(find.text('Welcome, admin!'), findsOneWidget);

      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pumpAndSettle();
      expect(find.text('15.0'), findsOneWidget);
      expect(find.text('10.0 + 5.0'), findsOneWidget);

      // 8. Social Page
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle();
      expect(find.text('Social Media'), findsOneWidget);

      // 9. Like a post and add a comment
      expect(find.text('Like'), findsWidgets);
      await tester.tap(find.text('Like').first);
      await tester.pumpAndSettle();
      expect(find.text('Liked'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Add a comment...').first,
        'Great post!',
      );
      await tester.tap(find.byTooltip('Send comment').first);
      await tester.pumpAndSettle();
      expect(find.text('Great post!'), findsOneWidget);

      // 10. Switch tabs and return to Social -> Posts, likes, and comments remain
      await tester.tap(find.byType(NavigationDestination).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle();
      expect(find.text('Liked'), findsOneWidget);
      expect(find.text('Great post!'), findsOneWidget);

      // 11. Open Profile -> Student information and username appear
      await tester.tap(find.byType(NavigationDestination).at(3));
      await tester.pumpAndSettle();
      expect(find.text('Exequiel Arco'), findsOneWidget);
      expect(find.text('Logged in as: admin'), findsOneWidget);
      expect(find.text('554948'), findsOneWidget);
      expect(find.text('BSIT — CCE1056L (3447)'), findsOneWidget);
      expect(find.text('e.arco.554948@umindanao.edu.ph'), findsOneWidget);

      // 12. Tap Logout -> Login appears
      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsWidgets);
      expect(DemoAuth.currentUsername, isNull);

      // 13. Register a valid account and log in
      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();
      expect(find.text('Create an Account'), findsOneWidget);

      // Try invalid registrations
      // Username < 3
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'ab',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '123456',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        '123456',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pumpAndSettle();
      expect(find.text('At least 3 characters are required.'), findsOneWidget);

      // Reserved admin
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'admin',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pumpAndSettle();
      expect(find.text('admin is reserved.'), findsOneWidget);

      // Valid user registration
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'exequiel',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'secret123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pumpAndSettle();

      // Returns to Login screen
      expect(find.text('Login'), findsWidgets);
      expect(
        find.text('Registration successful! You can now log in.'),
        findsOneWidget,
      );

      // Wait for SnackBar to dismiss
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Log in with registered credentials
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'exequiel',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Check dashboard has registered username
      expect(find.text('Welcome, exequiel!'), findsOneWidget);

      // 14. Create a post using the registered account
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Create Post'), findsWidgets);

      await tester.enterText(
        find.widgetWithText(TextField, 'Caption'),
        'New post by exequiel',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Image URL'),
        'https://picsum.photos/id/10/600/400',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
      await tester.pumpAndSettle();

      // Post displays the registered username
      expect(find.text('exequiel'), findsOneWidget);
      expect(find.text('New post by exequiel'), findsOneWidget);

      // Check profile has registered username
      await tester.tap(find.byType(NavigationDestination).at(3));
      await tester.pumpAndSettle();
      expect(find.text('Logged in as: exequiel'), findsOneWidget);
    },
  );
}
