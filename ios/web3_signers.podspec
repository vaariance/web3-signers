#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'web3_signers'
  s.version          = '0.0.1'
  s.summary          = 'Platform Key Signer'
  s.description      = <<-DESC
This Flutter plugin provides means to perform pkcs based signing of messages with secure element.
                       DESC
  s.homepage         = 'https://github.com/vaariance/web3-signers'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Variance' => 'team@variance.space' }
  s.source           = { :http => 'https://github.com/vaariance/web3-signers/tree/main' }
  s.documentation_url = 'https://pub.dev/packages/web3_signers'
  s.source_files = 'web3_signers/Sources/web3_signers/**/*.swift'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.5'
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.resource_bundles = {'web3_signers_privacy' => ['web3_signers/Sources/web3_signers/PrivacyInfo.xcprivacy']}
end