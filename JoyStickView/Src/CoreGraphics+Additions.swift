// Copyright © 2020 Brad Howes. All rights reserved.

import CoreGraphics

/// Convenience functions for CGRect.
public extension CGRect {
    /// Obtain the center of a CGRect.
    var mid: CGPoint { .init(x: midX, y: midY) }
}

/// Convenience functions for CGVector.
public extension CGVector {
    /**
     Multiply the components of a CGVector by a scalar
     - parameter lhs: the CGVector to multiply
     - parameter rhs: the scalar to multiply
     - returns new CGVector
     */
    static func *(lhs: CGVector, rhs: CGFloat) -> CGVector { .init(dx: lhs.dx * rhs, dy: lhs.dy * rhs) }

    /**
     Multiply the components of a CGVector by a scalar
     - parameter lhs: the CGVector to multiply
     - parameter rhs: the scalar to muliply
     - returns new CGVector
     */
    static func *(lhs: CGVector, rhs: Double) -> CGVector { lhs * CGFloat(rhs) }

    /// Obtain the squared magnitude of the CGVector
    var magnitude2: CGFloat { dx * dx + dy * dy }
    /// Obtain the magnitude of the CGVector
    var magnitude: CGFloat { sqrt(magnitude2) }
}

/// Convenience functions for CGPoint.
public extension CGPoint {
    /**
     Add the components of a CGPoint and a CGVector
     - parameter lhs: the CGPoint to add
     - parameter rhs: the CGVector to add
     - returns: new CGPoint representing the sum
     */
    static func + (lhs: CGPoint, rhs: CGVector) -> CGPoint { .init(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy) }

    /**
     Add the components of a CGPoint and a CGSize
     - parameter lhs: the CGPoint to add
     - parameter rhs: the CGSize to add
     - returns: new CGPoint representing the sum
     */
    static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint { .init(x: lhs.x + rhs.width, y: lhs.y + rhs.height) }

    /**
     Subtract the components of a CGPoint and a CGVector
     - parameter lhs: the CGPoint to subtract
     - parameter rhs: the CGVector to subtract
     - returns: new CGPoint representing the difference
     */
    static func - (lhs: CGPoint, rhs: CGVector) -> CGPoint { .init(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy) }

    /**
     Subtract the components of a CGPoint and a CGSize
     - parameter lhs: the CGPoint to subtract
     - parameter rhs: the CGSize to subtract
     - returns: new CGPoint representing the difference
     */
    static func - (lhs: CGPoint, rhs: CGSize) -> CGPoint { .init(x: lhs.x - rhs.width, y: lhs.y - rhs.height) }

    /**
     Subtract the components of two CGPoint values
     - parameter lhs: the CGPoint to subtract
     - parameter rhs: the CGPoint to subtract
     - returns: new CGVector representing the difference
     */
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGVector { .init(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y) }
}

/// Convenience functions for CGSize.
public extension CGSize {
    /**
     Add two CGSize values
     - parameter lhs: the CGSize to add
     - parameter rhs: the CGSize to add
     - returns: new CGSize representing the sum
     */
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    /**
     Multiply the components of a CGSize value by a scalar
     - parameter lhs: the CGSize to multiply
     - parameter rhs: the scalar to multiply
     - returns: new CGSize representing the result
     */
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        .init(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    /**
     Divide the components of a CGSize value by a scalar
     - parameter lhs: the CGSize to divide
     - parameter rhs: the scalar to divide
     - returns: new CGSize representing the result
     */
    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        .init(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    /**
     Divide the components of two CGSize values
     - parameter lhs: the CGSize to divide
     - parameter rhs: the CGSize to divide
     - returns: new CGSize representing the result
     */
    static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        .init(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
}
