/*:
 # Demo
 
 We will create a simple view with two joysticks: a green on the left which is fixed, and a
 yellow one on the right which can move. For the demo to work, you will need to perform a
 couple of steps:
 
 * Build the JoyStickView framework -- select "Product > Build" menu item
 * Enable the Assistant Editor -- select "View > Assistant Edtitor > Show Assistant Editor" menu item
 * Select Live View at the top of the Assistant Editor

 */
import PlaygroundSupport
import UIKit
import CoreGraphics
import JoyStickView

/*:
 Create the top-level view with a redish hue to represent the area where the yellow joystick
 cannot move into. This will be the view of the playground.
 */

let rect = CGRect(x:0 , y:0, width: 500, height: 400)
let view = UIView(frame: rect)
view.translatesAutoresizingMaskIntoConstraints = true
view.backgroundColor = UIColor(hue: 1.0, saturation: 0.5, brightness: 1.0, alpha: 1.0)
PlaygroundPage.current.liveView = view

/*:
 Create another view with a white background to hold the joysticks.
 */
let movableBounds = view.bounds.insetBy(dx: 50.0, dy: 50.0)
let boundsView = UIView(frame: movableBounds)
boundsView.backgroundColor = UIColor.white.withAlphaComponent(1.0)
view.addSubview(boundsView)

/*:
 Create label to show a joystick's direction. WHen the joystick is moved up it will read 0°
 or "north", and when it is moved down it will read 180° or "south". To the right will read
 90°, while to the left will be 270°.
*/
let angleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 200, height: 26))
angleLabel.text = "0°"
angleLabel.textColor = UIColor.black
view.addSubview(angleLabel)

/*:
 And a label to show a joystick's displacement, which will range between 0 and 1.
*/
let displacementLabel = UILabel(frame: CGRect(x: 10, y: 36, width: 200, height: 26))
displacementLabel.text = "0.0"
displacementLabel.textColor = UIColor.black
view.addSubview(displacementLabel)

/*:
 Create the green, 'fixed' joystick.
*/
let size = CGSize(width: 100.0, height: 100.0)
let joystickFrame = CGRect(origin: CGPoint(x: 0.0, y: (rect.height - size.height) / 2.0), size: size)
let joystick1 = JoyStickView(frame: joystickFrame.offsetBy(dx: 60.0, dy: 0.0))
view.addSubview(joystick1)
joystick1.movable = false
joystick1.alpha = 1.0
joystick1.baseAlpha = 1.0
joystick1.handleAlpha = 0.75
joystick1.handleTintColor = UIColor.green // Colorize the handle

// Show the joystick's orientation in the labels
//
joystick1.monitor = { (angle: CGFloat, displacement: CGFloat) in
    angleLabel.text = "\(Int(angle))°"
    displacementLabel.text = "\(displacement)"
}

/*:
 Finally, create the yellow, 'movable' joystick.
*/
let joystick2 = JoyStickView(frame: joystickFrame.offsetBy(dx: rect.width - 60.0 - size.width, dy: 0.0))
view.addSubview(joystick2)
joystick2.movable = true
joystick2.movableBounds = movableBounds
joystick2.baseAlpha = 0.5
joystick2.handleAlpha = 0.75
joystick2.handleTintColor = UIColor.yellow

// Show the joystick's orientation in the labels
//
joystick2.monitor = { (angle: CGFloat, displacement: CGFloat) in
    angleLabel.text = "\(Int(angle))°"
    displacementLabel.text = "\(displacement)"
}

