#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fl_channel.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fl_channel'
  s.version          = '2.0.0'
  s.summary          = 'Native channel communication for Flutter on Android, iOS, macOS and HarmonyOS.'
  s.description      = <<-DESC
Native channel communication for Flutter on Android, iOS, macOS and HarmonyOS (OHOS),
with event channels, lifecycle control and native-to-Flutter messaging.
                       DESC
  s.homepage         = 'https://github.com/Wayaer/fl_channel'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Wayaer' => 'https://github.com/Wayaer' }
  s.source           = { :http => 'https://github.com/Wayaer/fl_channel' }
  s.documentation_url = 'https://pub.dev/packages/fl_channel'
  s.source_files = 'fl_channel/Sources/fl_channel/**/*.swift'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.ios.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.osx.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
  s.resource_bundles = { 'fl_channel_privacy' => ['fl_channel/Sources/fl_channel/PrivacyInfo.xcprivacy'] }
end
