import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('MaterialAppWithTheme', () {
    //final materialAppFinder = find.byValueKey('MaterialApp');
    final title = find.byValueKey('MaterialApp');

    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
      }
    });

    test('test splashscreen', () async {
      await driver.getRenderTree();
    });
  });
}
