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

    @IBOutlet weak var leftMagnitude: UILabel!
    @IBOutlet weak var leftTheta: UILabel!
    @IBOutlet weak var rightMagnitude: UILabel!
    @IBOutlet weak var rightTheta: UILabel!

    var joystick1: JoyStickView!
    var joystick2: JoyStickView!

    override func viewDidLoad() {
        super.viewDidLoad()

        joystick1 = makeJoystick(tintColor: UIColor.green) { angle, displacement in
            self.leftTheta.text = "\(angle)"
            self.leftMagnitude.text = "\(displacement)"
        }
        joystick1.movable = false
        joystick1.travel = 1.25

        joystick2 = makeJoystick(tintColor: UIColor.blue) { angle, displacement in
            self.rightTheta.text = "\(angle)"
            self.rightMagnitude.text = "\(displacement)"
        }

        // Show that we can customize the image shown in the view.
        let customImage = UIImage(named: "JoyStickBaseCustom")
        joystick2.baseImage = customImage
    }

    private func makeJoystick(tintColor: UIColor, monitor: @escaping JoyStickViewMonitor) -> JoyStickView {
        let frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: joystickSpan, height: joystickSpan))
        let joystick = JoyStickView(frame: frame)
        view.addSubview(joystick)
        joystick.monitor = monitor
        joystick.alpha = 1.0
        joystick.baseAlpha = 0.5
        joystick.handleTintColor = tintColor

        return joystick
    }

    private func repositionJoysticks(size: CGSize, offset1: CGSize, offset2: CGSize) {
        joystick1.center = CGPoint(x:              offset1.width, y: size.height - offset1.height)
        joystick2.center = CGPoint(x: size.width - offset2.width, y: size.height - offset2.height)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let span = joystickOffset + joystickSpan / 2.0
        let offset = CGSize(width: span, height: span)
        repositionJoysticks(size: view.bounds.size, offset1: offset, offset2: offset)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Record the offsets of each joystick so we can put them in the same place after the rotation.
        let offset1 = CGSize(width:                     joystick1.center.x, height: view.bounds.height - joystick1.center.y)
        let offset2 = CGSize(width: view.bounds.width - joystick2.center.x, height: view.bounds.height - joystick2.center.y)

        coordinator.animate(alongsideTransition: { context in
            self.repositionJoysticks(size: size, offset1: offset1, offset2: offset2)
        }, completion: { _ in
            // Just to make sure that we end up at the right spot
            self.repositionJoysticks(size: size, offset1: offset1, offset2: offset2)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

