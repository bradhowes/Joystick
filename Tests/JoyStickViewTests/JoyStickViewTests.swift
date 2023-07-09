// Copyright © 2019 Brad Howes. All rights reserved.

import XCTest
@testable import JoyStickView

class JoyStickViewTests: XCTestCase {

  var jsv: JoyStickView!

  override func setUp() {
    jsv = JoyStickView(frame: .init(x: 0, y: 0, width: 120, height: 120))
  }

  override func tearDown() {}

  func testTappedBlock() {
    jsv.tappedBlock = nil
    jsv.tappedBlock = { print("fired!") }
    jsv.tappedBlock = nil
  }

  func testHandleConstraint() {
    jsv.tappedBlock = nil
    jsv.tappedBlock = { print("fired!") }
    jsv.tappedBlock = nil
  }

  func testMovableBounds() {
    jsv.movableBounds = nil
    jsv.movableBounds = .init(x: 0, y: 0, width: 30, height: 30)
    jsv.movableBounds = nil
  }

  func testBaseAlpha() {
    jsv.baseAlpha = 0.3
    XCTAssertEqual(jsv.baseAlpha, 0.3, accuracy: 0.0001)
  }

  func testHandleAlpha() {
    jsv.handleAlpha = 0.34
    XCTAssertEqual(jsv.handleAlpha, 0.34, accuracy: 0.0001)
  }

  func testHandleTintColor() {
    jsv.handleTintColor = .systemRed
  }

  func testHandleSizeRatio() {
    jsv.handleSizeRatio = 0.5
  }

  func testXYMonitor() {
    var xSaw: Double = 0.0
    var ySaw: Double = 0.0
    jsv.setXYMonitor { x, y in
      print(x, y)
      xSaw = x
      ySaw = y
    }
    jsv.handleImageView.center = jsv.bounds.mid + CGVector(dx: 50.0, dy: 50.0)
    jsv.reportPosition()
    XCTAssertEqual(xSaw, 110.0)
    XCTAssertEqual(ySaw, -110.0)
  }

  func testPolarMonitor() {
    var sawTheta: Double = -1.0
    var sawDisplacement: Double = -1.0
    jsv.setPolarMonitor { theta, displacement in
      sawTheta = theta
      sawDisplacement = displacement
    }
    jsv.handleImageView.center = jsv.bounds.mid + CGVector(dx: 50.0, dy: 50.0)
    jsv.reportPosition()
    XCTAssertEqual(sawTheta, 135.0)
    XCTAssertEqual(sawDisplacement, 2.592724864350674)
  }
}
