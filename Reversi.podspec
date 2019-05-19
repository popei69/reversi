#
# Be sure to run `pod lib lint Reversi.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Reversi'
  s.version          = '1.0.0'
  s.summary          = 'An A/B Testing framework written in Swift.'
  s.description      = <<-DESC
Every iOS app should be able to implement A/B test without only relying on external services.
Reversi is an open source A/B Testing framework written in Swift to keep a clean code white creating UI varations.
                       DESC

  s.homepage         = 'https://github.com/popei69/Reversi'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'popei69' => 'b.pasquier69@gmail.com' }
  s.source           = { :git => 'https://github.com/popei69/Reversi.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/BenoitPasquier_'
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source_files = 'Reversi/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Reversi' => ['Reversi/Assets/*.png']
  # }
end
