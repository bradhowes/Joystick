// Copyright © 2023 Brad Howes. All rights reserved.

import XCTest
@testable import JoyStickView

class CoreGraphicsAdditionsTests: XCTestCase {

  func testCGRectMid() {
    let rect = CGRect(x: 0, y: 0, width: 100, height: 220)
    XCTAssertEqual(rect.mid, CGPoint(x: 50, y: 110))
  }

  func testCGVectorMagnitude() {
    let v1 = CGVector(dx: 1.23, dy: 4.5)
    XCTAssertEqual(v1.magnitude, sqrt(v1.dx * v1.dx + v1.dy * v1.dy))
  }

  func testCGVectorMagnitudeSquared() {
    let v1 = CGVector(dx: 1.23, dy: 4.5)
    XCTAssertEqual(v1.magnitude2, v1.dx * v1.dx + v1.dy * v1.dy)
  }

  func testCGPointPlusCGVector() {
    let p1 = CGPoint(x: 1.2, y: 3.4)
    let v1 = CGVector(dx: 5.6, dy: 7.8)
    XCTAssertEqual(p1 + v1, CGPoint(x: p1.x + v1.dx, y:  p1.y + v1.dy))
  }

  func testCGPointPlusCGSize() {
    let p1 = CGPoint(x: 1.2, y: 3.4)
    let s1 = CGSize(width: 5.6, height: 7.8)
    XCTAssertEqual(p1 + s1, CGPoint(x: p1.x + s1.width, y:  p1.y + s1.height))
  }

  func testCGPointMinusCGVector() {
    let p1 = CGPoint(x: 1.2, y: 3.4)
    let v1 = CGVector(dx: 5.6, dy: 7.8)
    XCTAssertEqual(p1 - v1, CGPoint(x: p1.x - v1.dx, y:  p1.y - v1.dy))
  }

  func testCGPointMinusCGPoint() {
    let p1 = CGPoint(x: 1.2, y: 3.4)
    let p2 = CGPoint(x: 5.6, y: 7.8)
    XCTAssertEqual(p1 - p2, CGVector(dx: p1.x - p2.x, dy:  p1.y - p2.y))
  }
}
