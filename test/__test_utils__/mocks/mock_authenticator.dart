import 'package:mocktail/mocktail.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'package:web3_signers/src/api/android_auth.g.dart' as android;
import 'package:web3_signers/src/api/darwin_auth.g.dart' as darwin;
import 'package:web3_signers/src/api/windows_auth.g.dart' as windows;

class MockPasskeyAuthenticator extends Mock implements PasskeyAuthenticator {}

class FakeAuthenticateRequestType extends Fake
    implements AuthenticateRequestType {}

class FakeRegisterRequestType extends Fake implements RegisterRequestType {}

class MockAndroidAuthenticator extends Mock
    implements android.PlatformAuthenticator {}

class MockDarwinAuthenticator extends Mock
    implements darwin.PlatformAuthenticator {}

class MockWindowsAuthenticator extends Mock
    implements windows.PlatformAuthenticator {}

class FakeAndroidOptions extends Fake implements android.AndroidOptions {}

class FakeDarwinOptions extends Fake implements darwin.DarwinOptions {}

class FakeWindowsOptions extends Fake implements windows.WindowsOptions {}
