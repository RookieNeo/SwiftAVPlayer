#
# Be sure to run `pod lib lint SwiftAVPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftAVPlayer'
  s.version          = '0.1.0'
  s.swift_version    = '4.0'
  s.summary          = 'A swift tool for AVFoundation easily to use.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A swift tool for AVFoundation easily to use.
                       DESC

  s.homepage         = 'https://github.com/Rookieneo/SwiftAVPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rookieneo' => 'rookieneo1224@gmail.com' }
  s.source           = { :git => 'https://github.com/Rookieneo/SwiftAVPlayer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'SwiftAVPlayer/Classes/**/{*.swift,*.xib}'
  s.resource = 'SwiftAVPlayer/Classes/Resources/Media.xcassets'
  # s.resource_bundles = {
  #   'SwiftAVPlayer' => ['SwiftAVPlayer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SnapKit'
end
