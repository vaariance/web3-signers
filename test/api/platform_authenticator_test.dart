import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3_signers/web3_signers.dart';

import '../__test_utils__/mocks/mock_authenticator.dart';

void main() {
  late PlatformAuthenticator authenticator;
  late MockAndroidAuthenticator mockAndroid;
  late MockDarwinAuthenticator mockDarwin;
  late MockWindowsAuthenticator mockWindows;

  final testKeyTag = 'test-key';
  final testSignature = Bytes.fromList([4, 5, 6]);
  final testPublicKey = Bytes.fromList([7, 8, 9]);

  // Options
  final androidOpts = AndroidPlatformOptions();
  final darwinOpts = DarwinPlatformOptions();
  final windowsOpts = WindowsPlatformOptions();

  setUpAll(() {
    registerFallbackValue(FakeAndroidOptions());
    registerFallbackValue(FakeDarwinOptions());
    registerFallbackValue(FakeWindowsOptions());
  });

  setUp(() {
    mockAndroid = MockAndroidAuthenticator();
    mockDarwin = MockDarwinAuthenticator();
    mockWindows = MockWindowsAuthenticator();

    authenticator = PlatformAuthenticator();
    authenticator.androidAuth = mockAndroid;
    authenticator.darwinAuth = mockDarwin;
    authenticator.windowsAuth = mockWindows;
  });

  group('PlatformAuthenticator', () {
    group('createKey', () {
      test('Android: delegates to androidAuth', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        when(
          () => mockAndroid.createKey(testKeyTag, any()),
        ).thenAnswer((_) async => testPublicKey);

        final result = await authenticator.createKey(testKeyTag, (
          android: androidOpts,
          darwin: null,
          windows: null,
        ));

        expect(result, testPublicKey);
        verify(() => mockAndroid.createKey(testKeyTag, androidOpts)).called(1);
        debugDefaultTargetPlatformOverride = null;
      });

      test('iOS: delegates to darwinAuth', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        when(
          () => mockDarwin.createKey(testKeyTag, any()),
        ).thenAnswer((_) async => testPublicKey);

        final result = await authenticator.createKey(testKeyTag, (
          android: null,
          darwin: darwinOpts,
          windows: null,
        ));

        expect(result, testPublicKey);
        verify(() => mockDarwin.createKey(testKeyTag, darwinOpts)).called(1);
        debugDefaultTargetPlatformOverride = null;
      });

      test('Windows: delegates to windowsAuth', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        when(
          () => mockWindows.createKey(testKeyTag, any()),
        ).thenAnswer((_) async => testPublicKey);

        final result = await authenticator.createKey(testKeyTag, (
          android: null,
          darwin: null,
          windows: windowsOpts,
        ));

        expect(result, testPublicKey);
        verify(() => mockWindows.createKey(testKeyTag, windowsOpts)).called(1);
        debugDefaultTargetPlatformOverride = null;
      });

      test('Throws ArgumentError if options missing', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        expect(
          () => authenticator.createKey(testKeyTag, (
            android: null,
            darwin: null,
            windows: null,
          )),
          throwsArgumentError,
        );
        debugDefaultTargetPlatformOverride = null;
      });

      test('Throws UnsupportedError for Linux', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;
        expect(
          () => authenticator.createKey(testKeyTag, (
            android: androidOpts,
            darwin: null,
            windows: null,
          )),
          throwsUnsupportedError,
        );

        expect(
          () => authenticator.deleteKey(testKeyTag),
          throwsUnsupportedError,
        );

        expect(
          () => authenticator.getPublicKey(testKeyTag),
          throwsUnsupportedError,
        );

        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('deleteKey', () {
      test('delegates deletion', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        when(() => mockAndroid.deleteKey(testKeyTag)).thenAnswer((_) async {});

        await authenticator.deleteKey(testKeyTag);
        verify(() => mockAndroid.deleteKey(testKeyTag)).called(1);

        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        when(() => mockWindows.deleteKey(testKeyTag)).thenAnswer((_) async {});

        await authenticator.deleteKey(testKeyTag);
        verify(() => mockWindows.deleteKey(testKeyTag)).called(1);

        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        when(() => mockDarwin.deleteKey(testKeyTag)).thenAnswer((_) async {});

        await authenticator.deleteKey(testKeyTag);
        verify(() => mockDarwin.deleteKey(testKeyTag)).called(1);
        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('getPublicKey', () {
      test('Returns null if not found', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        when(
          () => mockDarwin.getPublicKey(testKeyTag),
        ).thenAnswer((_) async => null);

        final result = await authenticator.getPublicKey(testKeyTag);
        expect(result, isNull);
        debugDefaultTargetPlatformOverride = null;
      });

      test('Returns key if found', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        when(
          () => mockDarwin.getPublicKey(testKeyTag),
        ).thenAnswer((_) async => testPublicKey);

        final result = await authenticator.getPublicKey(testKeyTag);
        expect(result, testPublicKey);
        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('sign', () {
      test('Android: delegates signing', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        when(
          () => mockAndroid.sign(testKeyTag, Bytes(32), any()),
        ).thenAnswer((_) async => testSignature);

        final result = await authenticator.sign(testKeyTag, Bytes(32), (
          android: androidOpts,
          darwin: null,
          windows: null,
        ));

        expect(result, testSignature);
        verify(
          () => mockAndroid.sign(testKeyTag, Bytes(32), androidOpts),
        ).called(1);
        debugDefaultTargetPlatformOverride = null;
      });

      test('Darwin: delegates signing (no opts needed)', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        when(
          () => mockDarwin.sign(testKeyTag, Bytes(32)),
        ).thenAnswer((_) async => testSignature);

        final result = await authenticator.sign(testKeyTag, Bytes(32), (
          android: null,
          darwin: darwinOpts,
          windows: null,
        ));

        expect(result, testSignature);
        verify(() => mockDarwin.sign(testKeyTag, Bytes(32))).called(1);
        debugDefaultTargetPlatformOverride = null;
      });

      test('Throws ArgumentError if options missing (Android)', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        expect(
          () => authenticator.sign(testKeyTag, Bytes(32), (
            android: null,
            darwin: null,
            windows: null,
          )),
          throwsArgumentError,
        );
        debugDefaultTargetPlatformOverride = null;
      });
    });
  });
}
