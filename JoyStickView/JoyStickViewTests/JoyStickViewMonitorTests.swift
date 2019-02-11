//
//  JoyStickViewTests.swift
//  JoyStickViewTests
//
//  Created by Brad Howes on 2/6/19.
//  Copyright © 2019 Brad Howes. All rights reserved.
//

import XCTest
import JoyStickView

class JoyStickViewMonitorTests: XCTestCase {

    var lastPolarReport: JoyStickViewPolarReport = JoyStickViewPolarReport(angle: 0.0, displacement: 0.0)
    lazy var polarMonitor = {report in self.lastPolarReport = report }
    
    var lastXYReport: JoyStickViewXYReport = JoyStickViewXYReport(x: 0.0, y: 0.0)
    lazy var xyMonitor = {report in self.lastXYReport = report }
    
    override func setUp() {
        
    }

    override func tearDown() {
        
    }

    func testPolarReporting() {
        let accuracy: CGFloat = 0.0000005
        let sinPi4: CGFloat =   0.70710678

        polarMonitor(JoyStickViewPolarReport(angle: 0.0, displacement: 10.0))
        XCTAssertEqual(lastPolarReport.angle, 0.0)
        XCTAssertEqual(lastPolarReport.displacement, 10.0)
        XCTAssertEqual(lastPolarReport.rectangular.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(lastPolarReport.rectangular.y, 10.0, accuracy: accuracy)

        polarMonitor(JoyStickViewPolarReport(angle: 45.0, displacement: 1.0))
        XCTAssertEqual(lastPolarReport.angle, 45.0)
        XCTAssertEqual(lastPolarReport.displacement, 1.0)
        XCTAssertEqual(lastPolarReport.rectangular.x, sinPi4, accuracy: accuracy)
        XCTAssertEqual(lastPolarReport.rectangular.y, sinPi4, accuracy: accuracy)

        polarMonitor(JoyStickViewPolarReport(angle: 90.0, displacement: 1.0))
        XCTAssertEqual(lastPolarReport.angle, 90.0)
        XCTAssertEqual(lastPolarReport.displacement, 1.0)
        XCTAssertEqual(lastPolarReport.rectangular.x, 1.0, accuracy: accuracy)
        XCTAssertEqual(lastPolarReport.rectangular.y, 0.0, accuracy: accuracy)

        polarMonitor(JoyStickViewPolarReport(angle: 135.0, displacement: 1.0))
        XCTAssertEqual(lastPolarReport.angle, 135.0)
        XCTAssertEqual(lastPolarReport.displacement, 1.0)
        XCTAssertEqual(lastPolarReport.rectangular.x, sinPi4, accuracy: accuracy)
        XCTAssertEqual(lastPolarReport.rectangular.y, -sinPi4, accuracy: accuracy)

        polarMonitor(JoyStickViewPolarReport(angle: 180.0, displacement: 0.5))
        XCTAssertEqual(lastPolarReport.angle, 180.0)
        XCTAssertEqual(lastPolarReport.displacement, 0.5)
        XCTAssertEqual(lastPolarReport.rectangular.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(lastPolarReport.rectangular.y, -0.5, accuracy: accuracy)

        polarMonitor(JoyStickViewPolarReport(angle: 225.0, displacement: 1.0))
        XCTAssertEqual(lastPolarReport.angle, 225.0)
        XCTAssertEqual(lastPolarReport.displacement, 1.0)
        XCTAssertEqual(lastPolarReport.rectangular.x, -sinPi4, accuracy: accuracy)
        XCTAssertEqual(lastPolarReport.rectangular.y, -sinPi4, accuracy: accuracy)

        polarMonitor(JoyStickViewPolarReport(angle: 270.0, displacement: 0.10))
        XCTAssertEqual(lastPolarReport.angle, 270.0)
        XCTAssertEqual(lastPolarReport.displacement, 0.1)
        XCTAssertEqual(lastPolarReport.rectangular.x, -0.1, accuracy: accuracy)
        XCTAssertEqual(lastPolarReport.rectangular.y, 0.0, accuracy: accuracy)

        polarMonitor(JoyStickViewPolarReport(angle: 315.0, displacement: 1.0))
        XCTAssertEqual(lastPolarReport.angle, 315.0)
        XCTAssertEqual(lastPolarReport.displacement, 1.0)
        XCTAssertEqual(lastPolarReport.rectangular.x, -sinPi4, accuracy: accuracy)
        XCTAssertEqual(lastPolarReport.rectangular.y, sinPi4, accuracy: accuracy)

        polarMonitor(JoyStickViewPolarReport(angle: 359.9, displacement: 1.0))
        XCTAssertEqual(lastPolarReport.angle, 359.9)
        XCTAssertEqual(lastPolarReport.displacement, 1.0)
        XCTAssertEqual(lastPolarReport.rectangular.x, -0.00174532, accuracy: accuracy)
        XCTAssertEqual(lastPolarReport.rectangular.y, 0.99999847, accuracy: accuracy)

        polarMonitor(JoyStickViewPolarReport(angle: 0.1, displacement: 1.0))
        XCTAssertEqual(lastPolarReport.angle, 0.1)
        XCTAssertEqual(lastPolarReport.displacement, 1.0)
        XCTAssertEqual(lastPolarReport.rectangular.x, 0.00174532, accuracy: accuracy)
        XCTAssertEqual(lastPolarReport.rectangular.y, 0.99999847, accuracy: accuracy)
    }

    func testRectangularReporting() {
        let accuracy: CGFloat = 0.0000005
    
        xyMonitor(JoyStickViewXYReport(x: 0.0, y: 1.0))
        XCTAssertEqual(lastXYReport.x, 0.0)
        XCTAssertEqual(lastXYReport.y, 1.0)
        XCTAssertEqual(lastXYReport.polar.angle, 0.0, accuracy: accuracy)
        XCTAssertEqual(lastXYReport.polar.displacement, 1.0, accuracy: accuracy)

        xyMonitor(JoyStickViewXYReport(x: 1.0, y: 1.0))
        XCTAssertEqual(lastXYReport.x, 1.0)
        XCTAssertEqual(lastXYReport.y, 1.0)
        XCTAssertEqual(lastXYReport.polar.angle, 45.0, accuracy: accuracy)
        XCTAssertEqual(lastXYReport.polar.displacement, CGFloat(2.0).squareRoot(), accuracy: accuracy)

        xyMonitor(JoyStickViewXYReport(x: 2.0, y: 0.0))
        XCTAssertEqual(lastXYReport.x, 2.0)
        XCTAssertEqual(lastXYReport.y, 0.0)
        XCTAssertEqual(lastXYReport.polar.angle, 90.0, accuracy: accuracy)
        XCTAssertEqual(lastXYReport.polar.displacement, 2.0, accuracy: accuracy)

        xyMonitor(JoyStickViewXYReport(x: 1.0, y: -1.0))
        XCTAssertEqual(lastXYReport.x, 1.0)
        XCTAssertEqual(lastXYReport.y, -1.0)
        XCTAssertEqual(lastXYReport.polar.angle, 135.0, accuracy: accuracy)
        XCTAssertEqual(lastXYReport.polar.displacement, CGFloat(2.0).squareRoot(), accuracy: accuracy)
        
        xyMonitor(JoyStickViewXYReport(x: 0.0, y: -1.0))
        XCTAssertEqual(lastXYReport.x, 0.0)
        XCTAssertEqual(lastXYReport.y, -1.0)
        XCTAssertEqual(lastXYReport.polar.angle, 180.0, accuracy: accuracy)
        XCTAssertEqual(lastXYReport.polar.displacement, CGFloat(1.0).squareRoot(), accuracy: accuracy)
        
        xyMonitor(JoyStickViewXYReport(x: -1.0, y: -1.0))
        XCTAssertEqual(lastXYReport.x, -1.0)
        XCTAssertEqual(lastXYReport.y, -1.0)
        XCTAssertEqual(lastXYReport.polar.angle, 225.0, accuracy: accuracy)
        XCTAssertEqual(lastXYReport.polar.displacement, CGFloat(2.0).squareRoot(), accuracy: accuracy)
        
        xyMonitor(JoyStickViewXYReport(x: -1.0, y: 0.0))
        XCTAssertEqual(lastXYReport.x, -1.0)
        XCTAssertEqual(lastXYReport.y, 0.0)
        XCTAssertEqual(lastXYReport.polar.angle, 270.0, accuracy: accuracy)
        XCTAssertEqual(lastXYReport.polar.displacement, CGFloat(1.0).squareRoot(), accuracy: accuracy)
        
        xyMonitor(JoyStickViewXYReport(x: -1.0, y: 1.0))
        XCTAssertEqual(lastXYReport.x, -1.0)
        XCTAssertEqual(lastXYReport.y, 1.0)
        XCTAssertEqual(lastXYReport.polar.angle, 315.0, accuracy: accuracy)
        XCTAssertEqual(lastXYReport.polar.displacement, CGFloat(2.0).squareRoot(), accuracy: accuracy)
        
        xyMonitor(JoyStickViewXYReport(x: -0.00174532, y: 0.99999847))
        XCTAssertEqual(lastXYReport.x, -0.00174532)
        XCTAssertEqual(lastXYReport.y, 0.99999847)
        XCTAssertEqual(lastXYReport.polar.angle, 359.9, accuracy: accuracy)
        XCTAssertEqual(lastXYReport.polar.displacement, CGFloat(1.0).squareRoot(), accuracy: accuracy)
        
        xyMonitor(JoyStickViewXYReport(x: 0.00174532, y: 0.99999847))
        XCTAssertEqual(lastXYReport.x, 0.00174532)
        XCTAssertEqual(lastXYReport.y, 0.99999847)
        XCTAssertEqual(lastXYReport.polar.angle, 0.1, accuracy: accuracy)
        XCTAssertEqual(lastXYReport.polar.displacement, CGFloat(1.0).squareRoot(), accuracy: accuracy)
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
