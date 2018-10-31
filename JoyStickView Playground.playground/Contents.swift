/*:
 # Demo
 
 We will create a simple view with two joysticks: a green one on the left which has a fixed base, and a
 yellow one on the right which has a base that can move. For the demo to work, you will need to perform a
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
let movableBounds = view.bounds.insetBy(dx: 100.0, dy: 100.0)
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
 Here is a simple function we will use to show the displacement and angle from a
 joystick.
*/
let monitor: JoyStickViewMonitor = { angle, displacement in
    angleLabel.text = String(format: "%.2f°", angle)
    displacementLabel.text = String(format: "%.3f", displacement)
}

/*:
 Create the green *fixed* joystick.
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

/*:
 Let the center of the green handle travel beyond the circumference of the base, by
 increasing travel radius by 25%.
 */
joystick1.travel = 1.25

/*:
 Show the joystick's orientation in the labels at the top of the view.
*/
joystick1.monitor = monitor

/*:
 Finally, create the yellow *movable* joystick. However, unlike the green one we will use a
 custom image for the handle, and will reduce the base alpha value to 0.5 so that it shows
 what is behind it. Also, restrict the movement of the joystick base by setting the
 `movableBounds` property.
*/
let joystick2 = JoyStickView(frame: joystickFrame.offsetBy(dx: rect.width - 60.0 - size.width, dy: 0.0))
view.addSubview(joystick2)
joystick2.movable = true
joystick2.movableBounds = movableBounds
joystick2.baseAlpha = 0.5
joystick2.handleImage = UIImage(named: "Star")
joystick2.handleSizeRatio = 1.0
joystick2.handleTintColor = UIColor.yellow

/*:
 Same as before, show the orientation in the labels
*/
joystick2.monitor = monitor

/*:
 Try moving the yellow joystick handle away from its base. As long as the handle lies within the white area, the base should move to keep the center of the handle on the circumference of the base (due to the `travel` property being 1.0).
 
 You can always reset the joystick to the original location by double-tapping on it.
*/
