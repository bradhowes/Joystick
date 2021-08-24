Pod::Spec.new do |s|
  s.name        = "BRHJoyStickView"
  s.version     = "3.1.2"
  s.summary     = "A custom UIView in Swift that presents a simple, configurable joystick interface."
  s.homepage    = "https://github.com/bradhowes/Joystick"
  s.license     = { :type => "MIT" }
  s.authors     = { "bradhowes" => "bradhowes@mac.com" }

  s.requires_arc = true
  s.swift_version = "5.4"
  s.ios.deployment_target = "11.0"
  s.source   = { :git => "https://github.com/bradhowes/Joystick.git", :tag => s.version }
  s.source_files = "JoyStickView/Sources/JoyStickView/*.swift"
  s.resource_bundle = { 'BRHJoyStickView' => 'JoyStickView/Sources/JoyStickView/Resources/*.xcassets' }
end
