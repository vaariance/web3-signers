#if os(macOS)
    import FlutterMacOS
#elseif os(iOS)
    import Flutter
#endif

public class PlatformAuthenticatorPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
            let messenger = registrar.messenger()
        #else
            let messenger = registrar.messenger
        #endif

        let authenticator = PlatformAuthenticatorImpl()

        PlatformAuthenticatorSetup.setUp(
            binaryMessenger: messenger,
            api: authenticator
        )
    }
}
