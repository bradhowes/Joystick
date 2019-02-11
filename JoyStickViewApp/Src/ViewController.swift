//
//  ViewController.swift
//  JoystickTestApp
//
//  Created by Bradley Howes on 8/24/17.
//  Copyright © 2017 Bradl Howes. All rights reserved.
//

import UIKit
import JoyStickView

class ViewController: UIViewController {
    let joystickOffset: CGFloat = 60.0
    let joystickSpan: CGFloat = 80.0

    var joystick1: JoyStickView!
    var joystick2: JoyStickView!
    
    @IBOutlet weak var magnitude: UILabel!
    @IBOutlet weak var theta: UILabel!
    @IBOutlet weak var constraint: UIView!
    @IBOutlet weak var joystick3: JoyStickView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let monitor: JoyStickViewPolarMonitor = { report in
            if report.displacement > 0.0 {
                self.theta.text = String(format: "%.3f", report.angle)
                self.magnitude.text = String(format: "%.3f", report.displacement)
            }
        }

        joystick1 = makeJoystick(tintColor: UIColor.green, monitor: monitor)
        joystick1.movable = false
        joystick1.travel = 1.25
        joystick1.accessibilityLabel = "leftJoystick"
        
        joystick2 = makeJoystick(tintColor: UIColor.magenta, monitor: monitor)

        // Show that we can customize the image shown in the view.
        let customImage = UIImage(named: "StarHandle")
        joystick2.movable = true
        joystick2.handleImage = customImage
        joystick2.handleSizeRatio = 1.0
        joystick2.accessibilityLabel = "rightJoystick"
        
        joystick3.monitor = .polar(monitor: monitor)
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

