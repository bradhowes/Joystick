//
//  JoyStickViewMonitor.swift
//  JoyStickView
//
//  Created by Brad Howes on 2/6/19.
//  Copyright © 2019 Brad Howes. All rights reserved.
//

import CoreGraphics

/**
 JoyStickView handle position as X, Y deltas from the base center. Note that here a positive `y` indicates that the
 joystick handle is pushed upwards.
 */
public struct JoyStickViewXYReport {
    public let x: CGFloat /// Delta X of handle from base center
    public let y: CGFloat /// Delta Y of handle from base center

    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
 
    /// Convert this report into polar format
    public var polar: JoyStickViewPolarReport {
        return JoyStickViewPolarReport(angle: (180.0 - atan2(x, -y) * 180.0 / .pi), displacement: sqrt(x * x + y * y))
    }
}

/**
 JoyStickView handle position as angle/displacement values from the base center. Note that `angle` is given in degrees,
 with 0° pointing up (north) and 90° pointing right (east).
 */
public struct JoyStickViewPolarReport {
    public let angle: CGFloat
    public let displacement: CGFloat

    public init(angle: CGFloat, displacement: CGFloat) {
        self.angle = angle
        self.displacement = displacement
    }
    
    /// Convert this report into XY format
    public var rectangular: JoyStickViewXYReport {
        let rads = angle * .pi / 180.0
        return JoyStickViewXYReport(x: sin(rads) * displacement, y: cos(rads) * displacement)
    }
}

public typealias JoyStickViewXYMonitor = (_ value: JoyStickViewXYReport) -> Void
public typealias JoyStickViewPolarMonitor = (_ value: JoyStickViewPolarReport) -> Void

/**
 Monitor kind. Determines the type of reporting that will be emitted from a JoyStickView instance.
 */
public enum JoyStickViewMonitorKind {
    case polar(monitor: JoyStickViewPolarMonitor)
    case xy(monitor: JoyStickViewXYMonitor)
    case none
}
