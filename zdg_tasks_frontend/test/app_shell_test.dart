import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zdg_tasks/core/token_store.dart';
import 'package:zdg_tasks/main.dart';
import 'package:zdg_tasks/shared/money.dart';

/// No platform channels in widget tests: an empty in-memory store.
class FakeTokenStore extends TokenStore {
  FakeTokenStore() : super(const FlutterSecureStorage());

  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

void main() {
  testWidgets('shell boots signed out and lands on the login screen',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [tokenStoreProvider.overrideWithValue(FakeTokenStore())],
      child: const ZdgTasksApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('ZDG Tasks'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });

  group('formatZmw', () {
    test('formats ngwee as ZMW with two decimals', () {
      expect(formatZmw(0), 'ZMW 0.00');
      expect(formatZmw(5), 'ZMW 0.05');
      expect(formatZmw(150), 'ZMW 1.50');
      expect(formatZmw(1234567), 'ZMW 12,345.67');
      expect(formatZmw(100000000), 'ZMW 1,000,000.00');
      expect(formatZmw(-250075), '-ZMW 2,500.75');
    });
  });

  group('parseZmwToNgwee', () {
    test('parses decimal input into integer ngwee without doubles', () {
      expect(parseZmwToNgwee('0'), 0);
      expect(parseZmwToNgwee('1'), 100);
      expect(parseZmwToNgwee('1.5'), 150);
      expect(parseZmwToNgwee('12,345.67'), 1234567);
      expect(parseZmwToNgwee('2500.75'), 250075);
      // Precision survives values that would drift through a double.
      expect(parseZmwToNgwee('92233720368547758.07'), 9223372036854775807);
    });

    test('rejects invalid input', () {
      expect(parseZmwToNgwee(''), isNull);
      expect(parseZmwToNgwee('abc'), isNull);
      expect(parseZmwToNgwee('1.234'), isNull);
      expect(parseZmwToNgwee('-5'), isNull);
    });
  });
}
