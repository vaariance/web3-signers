import Foundation

#if os(iOS)
    import Flutter
#elseif os(macOS)
    import FlutterMacOS
#endif

public class SwiftWeb3SignersPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let api = PlatformSigner()

        #if os(iOS)
            let messenger = registrar.messenger()
        #elseif os(macOS)
            let messenger = registrar.messenger
        #endif

        PlatformSignerApiSetup.setUp(binaryMessenger: messenger, api: api)
    }
}
