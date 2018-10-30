//
//  JoyStickView_AppUITests.swift
//  JoyStickView AppUITests
//
//  Created by Brad Howes on 10/29/18.
//  Copyright © 2018 Brad Howes. All rights reserved.
//

import XCTest
import JoyStickView

class JoyStickView_AppUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func center(of joystick: XCUIElement) -> XCUICoordinate {
        return joystick.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
    }
    
    func testFixedDirection(dx: CGFloat, dy: CGFloat, disp: Double, angle: Double, msg: String) {
        let app = XCUIApplication()
        let joystick = app.otherElements["leftJoystick"]
        let dispLabel = app.staticTexts["leftDisp"]
        let angleLabel = app.staticTexts["leftAngle"]

        // Press on the joystick and then drag it `dx/dy` points
        //
        let start = center(of: joystick)
        start.press(forDuration: 0.1, thenDragTo: start.withOffset(CGVector(dx: dx, dy: dy)))

        // Make sure that joystick report what we expect in displacement and angle
        //
        XCTAssertEqual(Double(dispLabel.label)!, disp, accuracy: 0.001, msg)
        XCTAssertEqual(Double(angleLabel.label)!, angle, accuracy: 0.001, msg)

        // Touch something else so we don't interfere with the joystick view while it moves back to its
        // home position.
        //
        center(of: dispLabel).press(forDuration: 0.1)
    }

    func testFixedDirections() {

        // Check the 4 axis
        let disp1 = 1.0
        testFixedDirection(dx:    0, dy: -200, disp: disp1, angle:   0.0, msg: "0")
        testFixedDirection(dx:  200, dy:    0, disp: disp1, angle:  90.0, msg: "1")
        testFixedDirection(dx:    0, dy:  200, disp: disp1, angle: 180.0, msg: "2")
        testFixedDirection(dx: -200, dy:    0, disp: disp1, angle: 270.0, msg: "3")

        // Check diagonals with movement that resuts in displacement < 1.0
        let disp2 = 0.664
        testFixedDirection(dx:  25, dy: -25, disp: disp2, angle:  45.0, msg: "5")
        testFixedDirection(dx:  25, dy:  25, disp: disp2, angle: 135.0, msg: "6")
        testFixedDirection(dx: -25, dy:  25, disp: disp2, angle: 225.0, msg: "7")
        testFixedDirection(dx: -25, dy: -25, disp: disp2, angle: 315.0, msg: "8")
    }

    func testMovable() {
        let app = XCUIApplication()
        let joystick = app.otherElements["rightJoystick"]
        let origin = joystick.frame
        let dispLabel = app.staticTexts["rightDisp"]
        let angleLabel = app.staticTexts["rightAngle"]
        
        // Move a large enough amount to move the base up.
        //
        let start = center(of: joystick)
        start.press(forDuration: 0.25, thenDragTo: start.withOffset(CGVector(dx: 0.0, dy: -100.0)))

        XCTAssertEqual(Float(dispLabel.label)!, 1.0, accuracy: 0.001)
        XCTAssertEqual(Float(angleLabel.label)!, 0.0, accuracy: 0.001)

        XCTAssertNotEqual(origin, joystick.frame)
        XCTAssertEqual(joystick.frame.origin.x, origin.origin.x, accuracy: 1.0)
        XCTAssertEqual(joystick.frame.origin.y, origin.origin.y - 100 + 44, accuracy: 1.0)

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
}