#
# Be sure to run `pod lib lint BigRest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BigRest"
  s.version          = "1.0.0"
  s.summary          = "A library for mapping RESTful JSON to NSManagedObjects. Go ahead, take a BigRest."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  A library that simplifies REST mapping to NSManagedObject subclasses. BigRest combines AFNetworking and MagicalRecord to make the REST -> POCSO pipeling from request to object as seamless as possible.
                       DESC

  s.homepage         = "https://github.com/bigworkindustries/BigRest"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Vincil Bishop" => "vincil@bigworkindustries.com" }
  s.source           = { :git => "https://github.com/bigworkindustries/BigRest.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  #s.resource_bundles = {
  #  'BigRest' => ['Pod/Assets/*.png']
  #}
  
  s.pod_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }
  s.user_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency "MagicalRecord", "~> 2.3.0"
  s.dependency "AFNetworking", "~>  2.6.0"
  s.dependency "EasyMapping", "~> 0.15.0"
  s.dependency "Underscore.m", "~> 0.2.0"
  # s.dependency "CocoaLumberjack", "~> 2.0.0"
end
