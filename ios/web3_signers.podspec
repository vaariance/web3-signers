#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint web3_signers.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'web3_signers'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin to enable p256 signatures by secure enclave.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://variance.space'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Variance' => 'team@variance.network' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.4'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
