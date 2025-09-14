import 'package:autocal/providers/event_provider.dart';
import 'package:autocal/services/shared_content_handler.dart';
import 'package:autocal/services/text_parser_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockWidgetRef extends Mock implements WidgetRef {}

class MockEventNotifier extends Mock implements EventNotifier {}

class MockTextParserService extends Mock implements TextParserService {}

void main() {
  group('SharedContentHandler Core Functionality', () {
    late SharedContentHandler handler;

    setUp(() {
      handler = SharedContentHandler();
    });

    group('URL Detection', () {
      test('should detect valid HTTP URLs', () {
        expect(handler.isUrlForTesting('http://example.com'), isTrue);
        expect(handler.isUrlForTesting('https://example.com'), isTrue);
        expect(
          handler.isUrlForTesting('https://www.example.com/path?query=value'),
          isTrue,
        );
      });

      test('should reject invalid URLs', () {
        expect(handler.isUrlForTesting('not a url'), isFalse);
        expect(handler.isUrlForTesting('ftp://example.com'), isFalse);
        expect(handler.isUrlForTesting(''), isFalse);
        expect(handler.isUrlForTesting('example.com'), isFalse);
      });
    });

    group('HTML Text Extraction', () {
      test('should extract text from simple HTML', () {
        const html =
            '<html><body><h1>Meeting Tomorrow</h1><p>At 2 PM in Conference Room A</p></body></html>';
        final result = handler.extractTextFromHtmlForTesting(html);
        expect(result, contains('Meeting Tomorrow'));
        expect(result, contains('At 2 PM in Conference Room A'));
        expect(result, isNot(contains('<h1>')));
        expect(result, isNot(contains('<p>')));
      });

      test('should remove script and style tags', () {
        const html = '''
          <html>
            <head>
              <style>body { color: red; }</style>
              <script>alert('test');</script>
            </head>
            <body>
              <h1>Important Meeting</h1>
              <script>console.log('remove me');</script>
            </body>
          </html>
        ''';
        final result = handler.extractTextFromHtmlForTesting(html);
        expect(result, contains('Important Meeting'));
        expect(result, isNot(contains('color: red')));
        expect(result, isNot(contains('alert')));
        expect(result, isNot(contains('console.log')));
      });

      test('should decode HTML entities', () {
        const html =
            '<p>Meeting &amp; Discussion at 3:00 PM &lt;Conference Room&gt;</p>';
        final result = handler.extractTextFromHtmlForTesting(html);
        expect(result, contains('Meeting & Discussion'));
        expect(result, contains('<Conference Room>'));
      });

      test('should handle malformed HTML gracefully', () {
        const html = '<p>Unclosed tag<div>Another unclosed<span>Text here';
        final result = handler.extractTextFromHtmlForTesting(html);
        expect(result, contains('Unclosed tag'));
        expect(result, contains('Another unclosed'));
        expect(result, contains('Text here'));
      });
    });

    group('Error Handling', () {
      test('should handle invalid URLs gracefully', () {
        expect(
          () => handler.handleSharedUrl('not a url'),
          throwsA(isA<SharedContentException>()),
        );
        expect(
          () => handler.handleSharedUrl(''),
          throwsA(isA<SharedContentException>()),
        );
      });
    });
  });
}
