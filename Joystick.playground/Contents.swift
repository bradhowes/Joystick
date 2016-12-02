import PlaygroundSupport
import UIKit
import CoreGraphics


let rect = CGRect(x:0 , y:0, width: 300, height: 400)
let view = UIView(frame: rect)
view.translatesAutoresizingMaskIntoConstraints = true
view.backgroundColor = UIColor.yellow

PlaygroundPage.current.liveView = view

// Label to show a joystick's direction
//
let angleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 200, height: 26))
angleLabel.text = "0°"
angleLabel.textColor = UIColor.black
view.addSubview(angleLabel)

// Label to show a joystick's displacement (0-1)
//
let displacementLabel = UILabel(frame: CGRect(x: 10, y: 36, width: 200, height: 26))
displacementLabel.text = "0.0"
displacementLabel.textColor = UIColor.black
view.addSubview(displacementLabel)

// Create 'fixed' joystick
//
let joystick1 = JoyStickView(frame: CGRect(x: 100.0, y: 60.0, width: 100.0, height: 100.0))
view.addSubview(joystick1)
joystick1.movable = false
joystick1.alpha = 1.0
joystick1.baseAlpha = 0.5 // let the background bleed thru the base
joystick1.handleTintColor = UIColor.green // Colorize the handle

// Show the joystick's orientation in the labels
//
joystick1.monitor = { (angle: CGFloat, displacement: CGFloat) in
    angleLabel.text = "\(Int(angle))°"
    displacementLabel.text = "\(displacement)"
}

// Create 'movable' joystick
//
let joystick2 = JoyStickView(frame: CGRect(x: 100.0, y: 220.0, width: 100.0, height: 100.0))
view.addSubview(joystick2)
joystick2.movable = true
joystick2.alpha = 0.3 // Blend in background with whole view
joystick2.handleTintColor = UIColor.red

// Show the joystick's orientation in the labels
//
joystick2.monitor = { (angle: CGFloat, displacement: CGFloat) in
    angleLabel.text = "\(Int(angle))°"
    displacementLabel.text = "\(displacement)"
}
