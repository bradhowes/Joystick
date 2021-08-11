// Copyright © 2020 Bradl Howes. All rights reserved.

import UIKit
import JoyStickView

class ViewController: UIViewController {
    let joystickOffset: CGFloat = 60.0
    let joystickSpan: CGFloat = 80.0

    var joystick1: JoyStickView!
    var joystick2: JoyStickView!
    
    @IBOutlet weak var magnitude: UILabel!
    @IBOutlet weak var theta: UILabel!
    @IBOutlet weak var fired: UILabel!
    @IBOutlet weak var constraint: UIView!
    @IBOutlet weak var joystick3: JoyStickView!

    var joystick4: JoyStickView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let monitor: JoyStickViewPolarMonitor = { report in
            if report.displacement > 0.0 {
                self.theta.text = String(format: "%.3f", report.angle)
                self.magnitude.text = String(format: "%.3f", report.displacement)
            }
        }

        fired.text = ""

        joystick1 = makeJoystick(tintColor: UIColor.green, monitor: monitor)
        joystick1.movable = false
        joystick1.travel = 1.25
        joystick1.accessibilityLabel = "leftJoystick"
        joystick1.enableDoubleTapForFrameReset = false
        joystick1.tappedBlock = {
            self.fired.text = "Fired!"
            Timer.scheduledTimer(withTimeInterval: TimeInterval(1.25), repeats: false) { timer in
                self.fired.text = ""
            }
        }

        joystick2 = makeJoystick(tintColor: UIColor.magenta, monitor: monitor)

        // Show that we can customize the image shown in the view.
        let customImage = UIImage(named: "StarHandle")
        joystick2.movable = true
        joystick2.handleImage = customImage
        joystick2.handleSizeRatio = 1.0
        joystick2.accessibilityLabel = "rightJoystick"
        joystick2.handleConstraint = CGRect(origin: CGPoint(x: 40, y: 0), size: CGSize(width: 0, height: 100))

        joystick3 = makePointyJoystick(tintColor: UIColor.systemTeal)
    }

    private func makeJoystick(tintColor: UIColor, monitor: @escaping JoyStickViewPolarMonitor) -> JoyStickView {
        let frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: joystickSpan, height: joystickSpan))
        let joystick = JoyStickView(frame: frame)
        view.addSubview(joystick)
        joystick.monitor = .polar(monitor: monitor)
        joystick.alpha = 1.0
        joystick.baseAlpha = 0.75
        joystick.handleTintColor = tintColor
        joystick.colorFillHandleImage = true
        return joystick
    }

    private func makePointyJoystick(tintColor: UIColor) -> JoyStickView {
        let frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: 150, height: 150))
        let joystick = JoyStickView(frame: frame)
        guard let pointyBase = UIImage(named: "PointedBase") else { fatalError() }
        guard let defaultBase = UIImage(named: "UnpointedBase") else { fatalError() }
        view.addSubview(joystick)

        let monitor: (JoyStickViewPolarReport) -> Void = { value in
            if value.displacement < 0.1 {
                joystick.baseImage = defaultBase
                return
            }

            let rotation = value.angle * CGFloat.pi / 180.0
            joystick.baseImage = pointyBase.rotate(radians: rotation)
        }

        joystick.baseImage = defaultBase
        joystick.monitor = .polar(monitor: monitor)
        joystick.alpha = 1.0
        joystick.baseAlpha = 0.5
        joystick.handleSizeRatio = 0.5
        joystick.handleAlpha = 0.5
        joystick.handleTintColor = tintColor
        joystick.colorFillHandleImage = true
        joystick.movable = false
        joystick.travel = 0.4
        return joystick
    }

    private func repositionJoysticks(size: CGSize) {
        
        // First joystick is fixed, so it always resides a fixed distance from the left and bottom edges of the device view
        //
        let span = joystickOffset + joystickSpan / 2.0
        let offset = CGSize(width: span, height: span)
        joystick1.center = CGPoint(x: offset.width, y: size.height - offset.height)

        // Second joystick is movable, but we constrain it to the view which is colored orange.
        //
        joystick2.movableBounds = constraint.frame
        joystick2.movableCenter = constraint.frame.mid
        joystick2.center = constraint.frame.mid

        joystick3.center = CGPoint(x: offset.width, y: size.height - offset.height * 3)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        repositionJoysticks(size: view.bounds.size)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            
        }, completion: { _ in
            self.repositionJoysticks(size: size)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIImage {

    func rotate(radians: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: size.width / 2, y: size.height / 2)
        context.rotate(by: CGFloat(radians))
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
