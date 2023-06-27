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
 Create a top-level view with a white background. This will be the view of the playground.
 */

let rect = CGRect(x:0 , y:0, width: 500, height: 400)
let view = UIView(frame: rect)
view.translatesAutoresizingMaskIntoConstraints = true
view.backgroundColor = .white
PlaygroundPage.current.liveView = view

let constrainAxis = UISwitch(frame: CGRect(x:240, y: 10, width: 100, height: 40))
view.addSubview(constrainAxis)

let constrainAxisLabel = UILabel(frame: CGRect(x:300, y: 6, width: 200, height: 40))
constrainAxisLabel.text = "Constrain Handle"
view.addSubview(constrainAxisLabel)

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
let monitor: JoyStickViewPolarMonitor = { report in
    angleLabel.text = String(format: "%.2f°", report.angle)
    displacementLabel.text = String(format: "%.3f", report.displacement)
}
monitor(JoyStickViewPolarReport(angle: 0.0, displacement: 0.0))

/*:
 Create the green *fixed* joystick. Let the handle reveal content underneath it with a 0.75 alpha value.
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
joystick1.baseImage = UIImage(named: "FancyBase", in: Bundle(for: JoyStickView.self), compatibleWith: nil)
joystick1.handleImage = UIImage(named: "FancyHandle", in: Bundle(for: JoyStickView.self), compatibleWith: nil)

/*:
 Let the center of the green handle travel beyond the circumference of the base, by
 increasing travel radius by 25%.
 */
joystick1.travel = 1.25

/*:
 Show the joystick's orientation in the labels at the top of the view.
*/
joystick1.monitor = .polar(monitor: monitor)

/*:
 Next we will create a *movable* joystick, one where the base will move if the handle is moved too far away
 from the base. However, we want to limit where the base can move, so we will create a pink area that will
 be the region where the base can move.
*/
let movableBounds = CGRect(x: 250, y: 100, width: 170, height: 200)
let boundsView = UIView(frame: movableBounds)
boundsView.backgroundColor = UIColor.red.withAlphaComponent(0.25)
view.addSubview(boundsView)

/*:
 Create the *movable* joystick. However, unlike the green one, we will use a
 custom image for the handle, and will reduce the base alpha value to 0.5 so that it shows
 what is behind it.
*/
let joystick2 = JoyStickView(frame: joystickFrame.offsetBy(dx: rect.width - 60.0 - size.width, dy: 0.0))
view.addSubview(joystick2)
joystick2.movable = true
joystick2.travel = 0.7
joystick2.baseAlpha = 0.5

/*:
 Customize the handle image.
 */
joystick2.handleImage = UIImage(named: "Star")
joystick2.handleSizeRatio = 0.9

/*:
 Tint it magenta and make the coloring uniform by using the "Star" image as a mask.
*/
joystick2.handleTintColor = UIColor.magenta
joystick2.colorFillHandleImage = true

/*:
 And restrict its movement.
 */
joystick2.movableBounds = movableBounds

/*:
 Same as before, show the orientation in the labels
*/
joystick2.monitor = .polar(monitor: monitor)

/*:
 Set up an event handler that will constrain the movement of the "Star" joystick to the vertical axis when
 the constrainAxis UISwitch is on.
*/
class Responder : NSObject {
    @objc func constrainAxisAction() {
        if constrainAxis.isOn {
            joystick2.handleConstraint = CGRect(origin: CGPoint(x: 49, y: 0), size: CGSize(width: 1, height: 100))
        }
        else {
            joystick2.handleConstraint = nil
        }
    }
}

let responder = Responder()
constrainAxis.addTarget(responder, action: #selector(Responder.constrainAxisAction), for: .touchUpInside)

/*:
 Try moving the "Star" joystick handle away from its base. As long as the handle lies within the pink area, the base
 should move to keep the center of the handle on the circumference of the base (due to the `travel` property being 1.0).
 
 You can reset the joystick to the original location by double-tapping on it. This behavior is configurable using the
 enableDoubleTapForFrameReset property.
*/
