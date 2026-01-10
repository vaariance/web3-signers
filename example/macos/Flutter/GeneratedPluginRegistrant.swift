//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import device_info_plus
import package_info_plus
import passkeys_darwin
import web3_signers

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  PasskeysPlugin.register(with: registry.registrar(forPlugin: "PasskeysPlugin"))
  PlatformAuthenticatorPlugin.register(with: registry.registrar(forPlugin: "PlatformAuthenticatorPlugin"))
}
