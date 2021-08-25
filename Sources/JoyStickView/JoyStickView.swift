// Copyright © 2020 Brad Howes. All rights reserved.

import UIKit
import CoreGraphics

/**
 A simple implementation of a joystick interface like those found on classic arcade games. This implementation detects
 and reports two values when the joystick moves:

 * angle: the direction the handle is pointing. Unit is degrees with 0° pointing up (north), and 90° pointing
 right (east).
 * displacement: how far from the view center the joystick is moved in the above direction. Unitless but
 is the ratio of distance moved from center over the radius of the joystick base. Always in range 0.0-1.0

 The view has several settable parameters that be used to configure a joystick's appearance and behavior:

 - monitor: an enumeration of type `JoyStickViewMonitorKind` that can hold a function to receive updates when the
 joystick's angle and/or displacement values change. Supports polar and cartesian (XY) reporting
 - movable: a boolean that when true lets the joystick move around in its parent's view when there joystick moves
 beyond displacement of 1.0.
 - movableBounds: a CGRect which limits where a movable joystick may travel
 - baseImage: a UIImage to use for the joystick's base
 - handleImage: a UIImage to use for the joystick's handle

 Additional documentation is available via the attribute names below.
 */
@IBDesignable public final class JoyStickView: UIView {

    /// Optional monitor which will receive updates as the joystick position changes. Supports polar and cartesian
    /// reporting. The function to call with a position report is held in the enumeration value.
    public var monitor: JoyStickViewMonitorKind = .none

    /// Optional block to be called upon a tap.
    public var tappedBlock: (() -> Void)? { didSet { installSingleTapGestureRecognizer() } }

    /// Optional rectangular region that restricts where the handle may move. The region should be defined in
    /// this view's coordinates. For instance, to constrain the handle in the Y direction with a UIView of size 100x100,
    /// use `CGRect(x: 50, y: 0, width: 1, height: 100)`
    public var handleConstraint: CGRect? {
        didSet {
            switch handleConstraint {
            case .some(let hc):
                handleCenterClamper = { .init(x: min(max($0.x, hc.minX), hc.maxX),
                                              y: min(max($0.y, hc.minY), hc.maxY)) }
            default:
                handleCenterClamper = { $0 }
            }
        }
    }

    /// The last-reported angle from the joystick handle. Unit is degrees, with 0° up (north) and 90° right (east).
    /// Note that this assumes that `angleRadians` was calculated with atan2(dx, dy) and that dy is positive when
    /// pointing down.
    public var angle: CGFloat { displacement != 0.0 ? 180.0 - angleRadians * 180.0 / .pi : 0.0 }

    /// The last-reported displacement from the joystick handle. Dimensionless but is the ratio of movement over
    /// the radius of the joystick base. Always falls between 0.0 and 1.0
    public private(set) var displacement: CGFloat = 0.0

    /// If `true` the joystick will move around in the parant's view so that the joystick handle is always at a
    /// displacement of 1.0. This is the default mode of operation. Setting to `false` will keep the view fixed.
    @IBInspectable public var movable: Bool = false

    /// The original location of a movable joystick. Used to restore its position when user double-taps on it.
    public var movableCenter: CGPoint? = nil

    /// Optional rectangular region that restricts where the base may move. The region should be defined in the
    /// this view's coordinates.
    public var movableBounds: CGRect? {
        didSet {
            switch movableBounds {
            case .some(let mb):
                baseCenterClamper = { .init(x: min(max($0.x, mb.minX), mb.maxX),
                                            y: min(max($0.y, mb.minY), mb.maxY)) }
            default:
                baseCenterClamper = { $0 }
            }
        }
    }

    /// The opacity of the base of the joystick. Note that this is different than the view's overall opacity
    /// setting. The end result will be a base image with an opacity of `baseAlpha` * `view.alpha`
    @IBInspectable public var baseAlpha: CGFloat {
        get { baseImageView.alpha }
        set { baseImageView.alpha = newValue }
    }

    /// The opacity of the handle of the joystick. Note that this is different than the view's overall opacity setting.
    /// The end result will be a handle image with an opacity of `handleAlpha` * `view.alpha`
    @IBInspectable public var handleAlpha: CGFloat {
        get { handleImageView.alpha }
        set { handleImageView.alpha = newValue }
    }

    /// The tintColor to apply to the handle. Changing it while joystick is visible will update the handle image.
    @IBInspectable public var handleTintColor: UIColor? = nil { didSet { generateHandleImage() } }

    /// Scaling factor to apply to the joystick handle. A value of 1.0 will result in no scaling of the image,
    /// however the default value is 0.85 due to historical reasons.
    @IBInspectable public var handleSizeRatio: CGFloat = 0.85 { didSet { scaleHandleImageView() } }

    /// Control how the handle image is generated. When this is `false` (default), a CIFilter will be used to tint
    /// the handle image with the `handleTintColor`. This results in a monochrome image of just one color, but with
    /// lighter and darker areas depending on the original image. When this is `true`, the handle image is just
    /// used as a mask, and all pixels with an alpha = 1.0 will be colored with the `handleTintColor` value.
    @IBInspectable public var colorFillHandleImage: Bool = false { didSet { generateHandleImage() } }

    /// Controls how far the handle can travel along the radius of the base. A value of 1.0 (default) will let the
    /// handle travel the full radius, with maximum travel leaving the center of the handle lying on the circumference
    /// of the base. A value greater than 1.0 will let the handle travel beyond the circumference of the base, while a
    /// value less than 1.0 will reduce the travel to values within the circumference. Note that regardless of this
    /// value, handle movements will always report displacement values between 0.0 and 1.0 inclusive.
    @IBInspectable public var travel: CGFloat = 1.0

    /// The image to use for the base of the joystick
    @IBInspectable public var baseImage: UIImage? { didSet { baseImageView.image = baseImage } }

    /// The image to use for the joystick handle
    @IBInspectable public var handleImage: UIImage? { didSet { generateHandleImage() } }

    /// Control whether view will recognize a double-tap gesture and move the joystick base to its original location
    /// when it happens. Note that this is only useful if `moveable` is true.
    @IBInspectable public var enableDoubleTapForFrameReset = true {
        didSet {
            if let gestureRecognizer = doubleTapGestureRecognizer {
                removeGestureRecognizer(gestureRecognizer)
                doubleTapGestureRecognizer = nil
            }
            if enableDoubleTapForFrameReset {
                installDoubleTapGestureRecognizer()
            }
        }
    }

    /**
     Position mode for a joystick handle. The default (original) is `absolute` mode.
     */
    public enum HandlePositionMode {
        /// Center of joystick handle moves to actual touch position (limited by base constraints)
        case absolute
        /// Center of joystick handle moves to delta between current touch position and first touch position
        case relative
    }

    /// How the handle is moved with the initial touch
    public var handlePositionMode: HandlePositionMode = .absolute

    /// Minimum distance in either X or Y coordinate the handle must move for `handleHasMoved` to return `true`.
    public var handleMovedTolerance: CGFloat = 2.0;

    /// The max distance the handle may move in any direction, where the start is the center of the joystick base and
    /// the end is on the circumference of the base when travel is 1.0.
    private var radius: CGFloat { self.bounds.size.width / 2.0 * travel }

    /// The image to use to show the base of the joystick
    private var baseImageView: UIImageView = .init(image: nil)

    /// The image to use to show the handle of the joystick
    private var handleImageView: UIImageView = .init(image: nil)

    /// Cache of the last joystick angle in radians
    private var angleRadians: CGFloat = 0.0

    /// A filter for joystick base centers. Used to restrict base movements.
    private var baseCenterClamper: (CGPoint) -> CGPoint = { $0 }

    /// A filter for joystick handle centers. Used to restrict handle movements.
    private var handleCenterClamper: (CGPoint) -> CGPoint = { $0 }

    /// Tap gesture recognizer for detecting single-taps. Only present if `tappedBlock` is not nil
    private var singleTapGestureRecognizer: UITapGestureRecognizer?

    /// Tap gesture recognizer for detecting double-taps. Only present if `enableSingleTapForFrameReset` is true
    private var doubleTapGestureRecognizer: UITapGestureRecognizer?

    /// The position of the initial touch on the handle
    private var tapPosition: CGPoint = .zero

    /// The timestamp of the initial touch on the handle
    private var tapStartTime: TimeInterval = 0.0

    /// Location of embedded resources
    private lazy var resourceBundle: Bundle = {
        #if SWIFT_PACKAGE

        return Bundle.module

        #else

        // CocoaPods embeds the resources bundle in the framework
        //
        let bundle = Bundle(for: JoyStickView.self)
        guard
            let path = bundle.path(forResource: "BRHJoyStickView", ofType: "bundle"),
            let embedded = Bundle(path: path)
        else {
            return bundle
        }

        return embedded
        #endif
    }()

    /**
     Initialize new joystick view using the given frame.
     - parameter frame: the location and size of the joystick
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    /**
     Initialize new joystick view from a file.
     - parameter coder: the source of the joystick configuration information
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Touch Handling

extension JoyStickView {

    /**
     A touch began in the joystick view
     - parameter touches: the set of UITouch instances, one for each touch event
     - parameter event: additional event info (ignored)
     */
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updatePosition(touch: touch, initial: true)
    }

    /**
     An existing touch has moved.
     - parameter touches: the set of UITouch instances, one for each touch event
     - parameter event: additional event info (ignored)
     */
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updatePosition(touch: touch, initial: false)
    }

    /**
     An existing touch event has been cancelled (probably due to system event such as an alert). Move joystick to
     center of base.
     - parameter touches: the set of UITouch instances, one for each touch event (ignored)
     - parameter event: additional event info (ignored)
     */
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        homePosition()
    }

    /**
     User removed touch from display. Move joystick to center of base.
     - parameter touches: the set of UITouch instances, one for each touch event (ignored)
     - parameter event: additional event info (ignored)
     */
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        homePosition()
    }

    /**
     Reset our base to the initial location before the user moved it. By default, this will take place
     whenever the user double-taps on the joystick handle.
     */
    @objc public func resetFrame() {
        guard let movableCenter = self.movableCenter, displacement < 0.5 else { return }
        center = movableCenter
    }
}

// MARK: - Implementation Details

extension JoyStickView {

    /**
     This is the appropriate place to configure our internal views as we have our own geometry.
     */
    public override func layoutSubviews() {
        super.layoutSubviews()
        initialize()
    }

    /**
     Common initialization of view. Creates UIImageView instances for base and handle.
     */
    private func initialize() {
        baseImageView.frame = bounds
        addSubview(baseImageView)

        scaleHandleImageView()
        addSubview(handleImageView)

        let bundle = self.resourceBundle

        if self.baseImage == nil,
           let baseImage = UIImage(named: "DefaultBase", in: bundle, compatibleWith: nil) {
            self.baseImage = baseImage
        }

        baseImageView.image = self.baseImage

        if self.handleImage == nil,
           let handleImage = UIImage(named: "DefaultHandle", in: bundle, compatibleWith: nil) {
            self.handleImage = handleImage
        }

        generateHandleImage()

        if enableDoubleTapForFrameReset {
            installDoubleTapGestureRecognizer()
        }
    }

    private func scaleHandleImageView() {
        let inset = (1.0 - handleSizeRatio) * bounds.width / 2.0
        handleImageView.frame = bounds.insetBy(dx: inset, dy: inset)
    }

    @objc private func emitSingleTap() {
        tappedBlock?()
    }
}

extension JoyStickView: UIGestureRecognizerDelegate {

    /**
     Install a UITapGestureRecognizer to detect and process single-tap activity on the joystick. If there is a
     double-tap gesture installed, establish failure dependency so that both will work.
     */
    private func installSingleTapGestureRecognizer() {
        if let gestureRecognizer = singleTapGestureRecognizer {
            removeGestureRecognizer(gestureRecognizer)
            singleTapGestureRecognizer = nil
        }

        if tappedBlock != nil {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(emitSingleTap))
            tapGestureRecognizer.delegate = self
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.numberOfTouchesRequired = 1
            tapGestureRecognizer.delaysTouchesEnded = false
            singleTapGestureRecognizer = tapGestureRecognizer
            addGestureRecognizer(tapGestureRecognizer)

            if let doubleTapGestureRecognizer = self.doubleTapGestureRecognizer {
                tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
            }
        }
    }

    /**
     Install a UITapGestureRecognizer to detect and process double-tap activity on the joystick. If there is a
     single-tap gesture installed, establish failure dependency so that both will work.
     */
    private func installDoubleTapGestureRecognizer() {
        if let gestureRecognizer = doubleTapGestureRecognizer {
            removeGestureRecognizer(gestureRecognizer)
            doubleTapGestureRecognizer = nil
        }

        if enableDoubleTapForFrameReset {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resetFrame))
            tapGestureRecognizer.delegate = self
            tapGestureRecognizer.numberOfTapsRequired = 2
            tapGestureRecognizer.numberOfTouchesRequired = 1
            tapGestureRecognizer.delaysTouchesEnded = false
            doubleTapGestureRecognizer = tapGestureRecognizer
            addGestureRecognizer(tapGestureRecognizer)

            if let singleTapGestureRecognizer = self.singleTapGestureRecognizer {
                singleTapGestureRecognizer.require(toFail: tapGestureRecognizer)
            }
        }
    }

    /// Returns `true` if the handle has moved, where moving means the displacement in either coordinate is
    /// `handleMovedTolerance` or greater.
    public var handleHasMoved: Bool {
        let change = handleImageView.center - bounds.mid
        return abs(change.dx) >= handleMovedTolerance || abs(change.dy) >= handleMovedTolerance
    }

    /**
     Implementation of gesture recognizer delegate method. Controls whether a gesture recognizer should continue to
     track events. This is always the case when in absolute mode (original behavior), but in relative mode it is only
     allowed until the handle has moved a meaningful amount.

     - parameter gestureRecognizer: the gesture recognizer being queried
     - returns: true if the gesture recognizer can continue to track events
     */
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return handlePositionMode == .absolute || !handleHasMoved
    }
}

extension JoyStickView {

    private func generateHandleImage() {
        if colorFillHandleImage {
            colorHandleImage()
        }
        else {
            tintHandleImage()
        }
    }

    /**
     Generate a handle image by applying the `handleTintColor` value to the handeImage
     */
    private func colorHandleImage() {
        guard let handleImage = self.handleImage else { return }
        if let handleTintColor = self.handleTintColor {
            let image = handleImage.withRenderingMode(.alwaysTemplate)
            handleImageView.image = image
            handleImageView.tintColor = handleTintColor
        }
        else {
            handleImageView.tintColor = nil
            handleImageView.image = handleImage
        }
    }

    private func tintHandleImage() {
        guard let handleImage = self.handleImage else { return }

        guard let handleTintColor = self.handleTintColor else {
            handleImageView.image = handleImage
            return
        }

        guard let inputImage = CIImage(image: handleImage) else {
            fatalError("failed to create input CIImage")
        }

        let filterConfig: [String:Any] = [kCIInputIntensityKey: 1.0,
                                          kCIInputColorKey: CIColor(color: handleTintColor),
                                          kCIInputImageKey: inputImage]
        #if swift(>=4.2)
        guard let filter = CIFilter(name: "CIColorMonochrome", parameters: filterConfig) else {
            fatalError("failed to create CIFilter CIColorMonochrome")
        }
        #else
        guard let filter = CIFilter(name: "CIColorMonochrome", withInputParameters: filterConfig) else {
            fatalError("failed to create CIFilter CIColorMonochrome")
        }
        #endif

        guard let outputImage = filter.outputImage else {
            fatalError("failed to obtain output CIImage")
        }

        handleImageView.image = UIImage(ciImage: outputImage)
    }

    /**
     Reset handle position so that it is in the center of the base.
     */
    private func homePosition() {
        handleImageView.center = bounds.mid
        reportPosition()
    }

    private func calculateDelta(location: CGPoint) -> CGVector {
        switch handlePositionMode {
        case .absolute: return location - frame.mid
        case .relative: return location - tapPosition
        }
    }

    /**
     Update the handle position based on the current touch location.
     - parameter touch: the UITouch instance describing where the finger/pencil is
     */
    private func updatePosition(touch: UITouch, initial: Bool) {
        guard let superview = self.superview else { return }
        let location = touch.location(in: superview)
        guard superview.bounds.contains(location) else { return }

        if initial {
            tapStartTime = touch.timestamp
            tapPosition = location
        }

        let delta = calculateDelta(location: location)
        let newDisplacement = delta.magnitude / radius

        // Calculate pointing angle used displacements. NOTE: using this ordering of dx, dy to atan2f to obtain
        // navigation angles where 0 is at top of clock dial and angle values increase in a clock-wise direction. This
        // also assumes that Y increases in the downward direction.
        //
        let newAngleRadians = atan2(delta.dx, delta.dy)

        if movable {
            if newDisplacement > 1.0 && repositionBase(location: location, angle: newAngleRadians) {
                repositionHandle(angle: newAngleRadians)
            }
            else {
                handleImageView.center = handleCenterClamper(bounds.mid + delta)
            }
        }
        else if newDisplacement > 1.0 {
            repositionHandle(angle: newAngleRadians)
        }
        else {
            handleImageView.center = handleCenterClamper(bounds.mid + delta)
        }

        reportPosition()
    }

    /**
     Report the current joystick values to any registered `monitor`.
     */
    private func reportPosition() {
        let delta = handleImageView.center - baseImageView.center
        let displacement = delta.magnitude2 == 0.0 ? 0.0 : delta.magnitude / radius
        let angleRadians = delta.magnitude2 == 0.0 ? 0.0 : atan2(delta.dx, delta.dy)

        self.displacement = displacement
        self.angleRadians = angleRadians

        switch monitor {
        case let .polar(monitor): monitor(JoyStickViewPolarReport(angle: self.angle, displacement: displacement))
        case let .xy(monitor): monitor(JoyStickViewXYReport(x: delta.dx, y: -delta.dy))
        case .none: break
        }
    }

    /**
     Move the base so that the handle displacement is `<=` 1.0 from the base. The last step of this operation is
     a clamping of the base origin so that it stays within a configured boundary. Such clamping can result in
     a joystick handle whose displacement is `>` 1.0 from the base, so the caller should account for that by looking
     for a `true` return value.

     - parameter location: the current joystick handle center position
     - parameter angle: the angle the handle makes with the center of the base
     - returns: true if the base **cannot** move sufficiently to keep the displacement of the handle <= 1.0
     */
    private func repositionBase(location: CGPoint, angle: CGFloat) -> Bool {
        if movableCenter == nil {
            movableCenter = self.center
        }

        // Calculate point that should be on the circumference of the base image.
        //
        let end = CGVector(dx: sin(angle) * radius, dy: cos(angle) * radius)

        // Calculate the origin of our frame, working backwards from the given location, and move to it.
        //
        let desiredCenter = location - end //  - frame.size / 2.0
        self.center = baseCenterClamper(desiredCenter)
        return self.center != desiredCenter
    }

    /**
     Move the joystick handle so that the angle made up of the triangle from the base 12:00 position on its
     circumference, the base center and the joystick center is the given value.

     - parameter angle: the angle (radians) to conform to
     */
    private func repositionHandle(angle: CGFloat) {

        // Keep handle on the circumference of the base image
        //
        let x = sin(angle) * radius
        let y = cos(angle) * radius
        handleImageView.frame.origin = .init(x: x + bounds.midX - handleImageView.bounds.size.width / 2.0,
                                             y: y + bounds.midY - handleImageView.bounds.size.height / 2.0)

        handleImageView.center = handleCenterClamper(handleImageView.center)
    }
}

/**
 Provide support for Obj-C monitors by wrapping a block in a closure that works with the Swift-only types.
 */
extension JoyStickView {

    /**
     Install an Obj-C block that will receive the polar coordinates of the joystick.

     - parameter block: the block to install. It must expect two CGFloat values, first being the angle, and the second
     being the displacement
     */
    @objc public func setPolarMonitor(_ block: @escaping (CGFloat, CGFloat) -> Void) {
        let bridge = {(report: JoyStickViewPolarReport) in block(report.angle, report.displacement) }
        monitor = .polar(monitor: bridge)
    }

    /**
     Install an Obj-C block that will receive the XY unit coordinates of the joystick.

     - parameter block: the block to install. It must expect two CGFloat values, first being the X unit coordinate, and
     the second being the Y unit coordinate.
     */
    @objc public func setXYMonitor(_ block: @escaping (CGFloat, CGFloat) -> Void) {
        let bridge = {(report: JoyStickViewXYReport) in block(report.x, report.y) }
        monitor = .xy(monitor: bridge)
    }
}
