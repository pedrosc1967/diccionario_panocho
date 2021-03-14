import 'package:flutter_test/flutter_test.dart';

void main() {
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows you to build and interact
  // with widgets in the test environment.
  testWidgets(
    'MyWidget has a title and message',
    (WidgetTester tester) async {
      // Test code goes here.

      /*
      // Create the widget by telling the tester to build it.
      await tester.pumpWidget(
        CustomDialogBox(
          title: 'Title',
          descriptions: 'Description',
          text: 'Pito',
          img: Image.asset("assets/logoaplanetbit.png"),
        ),
      );

      */
    },
  );
}
