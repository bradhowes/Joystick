// Copyright © 2020 Brad Howes. All rights reserved.

import CoreGraphics

/// Convenience functions for CGRect.
public extension CGRect {
  /// Obtain the center of a CGRect.
  @inlinable
  var mid: CGPoint { .init(x: midX, y: midY) }
}

/// Convenience functions for CGVector.
public extension CGVector {

  /// Obtain the squared magnitude of the CGVector
  @inlinable
  var magnitude2: CGFloat { dx * dx + dy * dy }

  /// Obtain the magnitude of the CGVector
  @inlinable
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
  @inlinable
  static func + (lhs: CGPoint, rhs: CGVector) -> CGPoint { .init(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy) }

  /**
   Add the components of a CGPoint and a CGSize
   - parameter lhs: the CGPoint to add
   - parameter rhs: the CGSize to add
   - returns: new CGPoint representing the sum
   */
  @inlinable
  static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint { .init(x: lhs.x + rhs.width, y: lhs.y + rhs.height) }

  /**
   Subtract the components of a CGPoint and a CGVector
   - parameter lhs: the CGPoint to subtract
   - parameter rhs: the CGVector to subtract
   - returns: new CGPoint representing the difference
   */
  @inlinable
  static func - (lhs: CGPoint, rhs: CGVector) -> CGPoint { .init(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy) }

  /**
   Subtract the components of two CGPoint values
   - parameter lhs: the CGPoint to subtract
   - parameter rhs: the CGPoint to subtract
   - returns: new CGVector representing the difference
   */
  @inlinable
  static func - (lhs: CGPoint, rhs: CGPoint) -> CGVector { .init(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y) }
}
