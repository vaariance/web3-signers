#import "SecureP256Plugin.h"
#if __has_include(<web3_signers/web3_signers-Swift.h>)
#import <web3_signers/web3_signers-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "web3_signers-Swift.h"
#endif

@implementation SecureP256Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftSecureP256Plugin registerWithRegistrar:registrar];
}
@end
