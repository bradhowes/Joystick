// Copyright © 2018 Brad Howes. All rights reserved.

import XCTest
import JoyStickView

class JoyStickView_AppUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        XCUIApplication().launch()
    }

    func center(of joystick: XCUIElement) -> XCUICoordinate {
        return joystick.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
    }
    
    func testFixedDirection(dx: CGFloat, dy: CGFloat, disp: Double, angle: Double, msg: String) {
        let app = XCUIApplication()
        let joystick = app.otherElements["leftJoystick"]
        let dispLabel = app.staticTexts["disp"]
        let angleLabel = app.staticTexts["angle"]

        // Press on the joystick and then drag it `dx/dy` points
        //
        let start = center(of: joystick)
        start.press(forDuration: 0.3, thenDragTo: start.withOffset(CGVector(dx: dx, dy: dy)), withVelocity: .default,
                    thenHoldForDuration: 0.3)

        // Make sure that joystick report what we expect in displacement and angle
        //
        XCTAssertEqual(Double(dispLabel.label)!, disp, accuracy: 0.25, msg)
        XCTAssertEqual(Double(angleLabel.label)!, angle, accuracy: 1.0, msg)

        // Touch something else so we don't interfere with the joystick view while it moves back to its
        // home position. NOTE: for some reason putting the duration value too low will cause tests to fail.
        //
        center(of: dispLabel).press(forDuration: 1.0)
    }

    func testFixedDirections() {

        // Check the 4 axis
        let disp1 = 1.0
        testFixedDirection(dx:    0, dy: -200, disp: disp1, angle:   0.0, msg: "0")
        testFixedDirection(dx:  200, dy:    0, disp: disp1, angle:  90.0, msg: "1")
        testFixedDirection(dx:    0, dy:  200, disp: disp1, angle: 180.0, msg: "2")
        testFixedDirection(dx: -200, dy:    0, disp: disp1, angle: 270.0, msg: "3")

        // Check diagonals with movement that resuts in displacement < 1.0
        let disp2 = 0.509
        testFixedDirection(dx:  25, dy: -25, disp: disp2, angle:  45.0, msg: "5")
        testFixedDirection(dx:  25, dy:  25, disp: disp2, angle: 135.0, msg: "6")
        testFixedDirection(dx: -25, dy:  25, disp: disp2, angle: 225.0, msg: "7")
        testFixedDirection(dx: -25, dy: -25, disp: disp2, angle: 315.0, msg: "8")
    }

    /**
     Test the movable properties of JoyStickView.
     
     NOTE: if this fails, it could be due to orientation of the simulator. Make sure that "Hardware > Rotate Device Automatically"
     menu item is selected in the simulator, and try again.
     */
    func testMovable() {
        
        let app = XCUIApplication()
        let joystick = app.otherElements["rightJoystick"]
        let origin = joystick.frame
        let dispLabel = app.staticTexts["disp"]
        let angleLabel = app.staticTexts["angle"]
        
        // Move a large enough amount to move the base up.
        //
        let start = center(of: joystick)
        start.press(forDuration: 0.25, thenDragTo: start.withOffset(CGVector(dx: 0.0, dy: -100.0)), withVelocity: .fast, thenHoldForDuration: 0.25)

        XCTAssertEqual(Float(dispLabel.label)!, 1.0, accuracy: 0.001)
        XCTAssertEqual(Float(angleLabel.label)!, 0.0, accuracy: 0.001)

        XCTAssertNotEqual(origin, joystick.frame)
        XCTAssertEqual(joystick.frame.origin.x, origin.origin.x, accuracy: 1.0)
        XCTAssertNotEqual(joystick.frame.origin.y, origin.origin.y, accuracy: 1.0)

        // Now double-tap to move back
        //
        let start2 = center(of: joystick)
        start2.press(forDuration: 0.1)
        start2.press(forDuration: 0.1)
        XCTAssertEqual(origin, joystick.frame)

        // Move to the left and make sure that joystick is constrained by the bounds
        //
        start.press(forDuration: 0.1, thenDragTo: start.withOffset(CGVector(dx: -400.0, dy: 0.0)))
        XCTAssertNotEqual(origin, joystick.frame)
        XCTAssertNotEqual(joystick.frame.origin.x, origin.origin.x - 400 + 44, accuracy: 1.0)
        XCTAssertEqual(joystick.frame.origin.y, origin.origin.y, accuracy: 1.0)
    }

    func testRelativeTapped() {

        let app = XCUIApplication()
        let joystick = app.otherElements["leftJoystick"]
        let origin = joystick.frame
        let dispLabel = app.staticTexts["disp"]
        let angleLabel = app.staticTexts["angle"]
        let firedLabel = app.staticTexts["fired"]
        let relativeMode = app.switches["relativeMode"]

        // Enable relative mode so that taps work as expected
        relativeMode.tap()

        XCTAssertEqual(dispLabel.label, "0.0")
        XCTAssertEqual(angleLabel.label, "0.0")

        // Tap off-center then move. Make sure that single-tap gesture did not fire.
        let start = center(of: joystick).withOffset(.init(dx: 30.0, dy: 5.0))
        start.press(forDuration: 0.25, thenDragTo: start.withOffset(CGVector(dx: 10.0, dy: -10.0)), withVelocity: .slow,
                    thenHoldForDuration: 0.25)

        XCTAssertEqual(origin, joystick.frame)
        XCTAssertEqual(dispLabel.label, "0.255")
        XCTAssertEqual(angleLabel.label, "45.000")
        if firedLabel.exists {
            XCTAssertEqual(firedLabel.label, "")
        }

        // Now just tap.
        start.press(forDuration: 0.1)
        XCTAssertEqual(origin, joystick.frame)

        XCTAssertEqual(dispLabel.label, "0.255")
        XCTAssertEqual(angleLabel.label, "45.000")
        XCTAssertEqual(firedLabel.label, "Fired!")
    }
}
