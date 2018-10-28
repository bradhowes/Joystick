import UIKit
import CoreGraphics

/**
 Type definition for a function that will receive updates from the JoyStickView when the handle moves. Takes two
 values, both CGFloats.
 
 - parameter angle: the direction the handle is pointing. Unit is degrees with 0° pointing up (north), and 90° pointing
 right (east).
 - parameter displacement: how far from the view center the joystick is moved in the above direction. Unitless but
 is the ratio of distance moved from center over the radius of the joystick base. Always in range 0.0-1.0
 */
public typealias JoyStickViewMonitor = (_ angle: CGFloat, _ displacement: CGFloat) -> ()

/**
 A simple implementation of a joystick interface like those found on classic arcade games. This implementation detects
 and reports two values when the joystick moves:

 * angle: the direction the handle is pointing. Unit is degrees with 0° pointing up (north), and 90° pointing
 right (east).
 * displacement: how far from the view center the joystick is moved in the above direction. Unitless but
 is the ratio of distance moved from center over the radius of the joystick base. Always in range 0.0-1.0

 The view has several settable parameters that be used to configure a joystick's appearance and behavior:

 - monitor: a function of type `JoyStickViewMonitor` that will receive updates when the joystick's angle and/or
 displacement values change.
 - movable: a boolean that when true lets the joystick move around in its parent's view when there joystick moves
 beyond displacement of 1.0.
 - movableBounds: a CGRect which limits where a movable joystick may travel
 - baseImage: a UIImage to use for the joystick's base
 - handleImage: a UIImage to use for the joystick's handle
 
 Additional documentation is available via the attribute names below.
 */
public final class JoyStickView: UIView {

    /// Holds a function to call when joystick orientation changes
    public var monitor: JoyStickViewMonitor? = nil

    /// If `true` the joystick will move around in the parant's view so that the joystick handle is always at a
    /// displacement of 1.0. This is the default mode of operation. Setting to `false` will keep the view fixed.
    public var movable: Bool = true

    /// Area where the joystick can move
    public var movableBounds: CGRect? {
        didSet {
            if let mb = movableBounds {

                // Create filter that constrains a point to the rectangle set in movableBounds
                originClamper = {
                    CGPoint(x: min(max($0.x, mb.minX), mb.maxX - self.frame.width),
                            y: min(max($0.y, mb.minY), mb.maxY - self.frame.height))
                }
            }
            else {

                // Identity filter
                originClamper = { $0 }
            }
        }
    }

    /// The opacity of the base of the joystick. Note that this is different than the view's overall opacity setting.
    /// The end result will be a base image with an opacity of `baseAlpha` * `view.alpha`
    public var baseAlpha: CGFloat {
        get {
            return baseImageView.alpha
        }
        set {
            baseImageView.alpha = newValue
        }
    }

    /// The opacity of the handle of the joystick. Note that this is different than the view's overall opacity setting.
    /// The end result will be a handle image with an opacity of `handleAlpha` * `view.alpha`
    public var handleAlpha: CGFloat {
        get {
            return handleImageView.alpha
        }
        set {
            handleImageView.alpha = newValue
        }
    }

    /// The tintColor to apply to the handle. By default, uses the view's tintColor value. Changing it while joystick
    /// is visible will update the handle image.
    public var handleTintColor: UIColor! {
        didSet { tintHandleImage() }
    }

    /// The last-reported angle from the joystick handle. Unit is degrees, with 0° up (north) and 90° right (east)
    public var angle: CGFloat { return displacement != 0.0 ? CGFloat(180.0 - lastAngleRadians * 180.0 / Float.pi) : 0.0 }

    /// The last-reported displacement from the joystick handle. Dimensionless but is the ratio of movement over
    /// the radius of the joystick base. Always falls between 0.0 and 1.0
    public private(set) var displacement: CGFloat = 0.0

    /// The radius of the base of the joystick, the max distance the handle may move in any direction.
    private lazy var radius: CGFloat = { return self.bounds.size.width / 2.0 }()

    /// The image to use for the base of the joystick
    public var baseImage: UIImage? {
        didSet {
            if baseImageView != nil {
                baseImageView.image = self.baseImage
            }
        }
    }

    /// The image to use for the joystick handle
    public var handleImage: UIImage? {
        didSet {
            if handleImageView != nil {
                tintHandleImage()
            }
        }
    }

    /// The image to use to show the base of the joystick
    private var baseImageView: UIImageView!

    /// The image to use to show the handle of the joystick
    private var handleImageView: UIImageView!

    /// Cache of the last joystick angle in radians
    private var lastAngleRadians: Float = 0.0

    /// The original location of the joystick. Used to restore its position when user double-taps on it.
    private var originalCenter: CGPoint?

    /// Tap gesture recognizer for double-taps which will reset the joystick position
    private var tapGestureRecognizer: UITapGestureRecognizer!

    private var originClamper: (CGPoint) -> CGPoint = { $0 }
    
    /**
     Initialize new joystick view using the given frame.
     - parameter frame: the location and size of the joystick
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    /**
     Initialize new joystick view from a file.
     - parameter coder: the source of the joystick configuration information
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    /**
     A touch began in the joystick view
     - parameter touches: the set of UITouch instances, one for each touch event
     - parameter event: additional event info (ignored)
     */
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updatePosition(touch: touch)
    }

    /**
     An existing touch has moved.
     - parameter touches: the set of UITouch instances, one for each touch event
     - parameter event: additional event info (ignored)
     */
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updatePosition(touch: touch)
    }

    /**
     An existing touch event has been cancelled (probably due to system event such as an alert). Move joystick to
     center of base.
     - parameter touches: the set of UITouch instances, one for each touch event (ignored)
     - parameter event: additional event info (ignored)
     */
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetPosition()
    }

    /**
     User removed touch from display. Move joystick to center of base.
     - parameter touches: the set of UITouch instances, one for each touch event (ignored)
     - parameter event: additional event info (ignored)
     */
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetPosition()
    }

    /**
     Reset our base to the initial location before the user moved it. By default, this will take place
     whenever the user double-taps on the joystick handle.
     */
    @objc public func resetFrame() {
        guard let originalCenter = self.originalCenter, displacement < 0.5 else { return }
        center = originalCenter
        self.originalCenter = nil
    }
}

extension JoyStickView {
    
    /**
     Common initialization of view. Creates UIImageView instances for base and handle.
     */
    private func initialize() {
        
        handleTintColor = tintColor

        // By default we will create UIImageView instances with our own images found in our bundle.
        // However, the API provides for custom images which will be used if set.
        //
        let bundle = Bundle(for: JoyStickView.self)
        baseImage = UIImage(named: "Images/JoyStickBase", in: bundle, compatibleWith: nil)

        baseImageView = UIImageView(image: baseImage)
        baseImageView.alpha = baseAlpha
        baseImageView.frame = bounds
        addSubview(baseImageView)

        handleImage = UIImage(named: "Images/JoyStickHandle", in: bundle, compatibleWith: nil)

        handleImageView = UIImageView(image: handleImage)
        tintHandleImage()
        handleImageView.frame = bounds.insetBy(dx: 0.15 * bounds.width, dy: 0.15 * bounds.height)
        handleImageView.alpha = handleAlpha
        addSubview(handleImageView)

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resetFrame))
        tapGestureRecognizer!.numberOfTapsRequired = 2
        addGestureRecognizer(tapGestureRecognizer!)
    }
    
    /**
     Generate a new handle image using the current `tintColor` value and install. Uses CoreImage filter to apply a
     tint to the grey handle image.
     */
    private func tintHandleImage() {
        guard let handleImage = self.handleImage, let handleImageView = self.handleImageView else { return }
        guard let inputImage = CIImage(image: handleImage) else {
            fatalError("failed to create input CIImage")
        }
        
        let filterConfig: [String:Any] = [kCIInputIntensityKey: 1.0,
                                          kCIInputColorKey: CIColor(color: handleTintColor!),
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
    private func resetPosition() {
        updateLocation(location: CGPoint(x: frame.midX, y: frame.midY))
    }

    /**
     Update the handle position based on the current touch location.
     - parameter touch: the UITouch instance describing where the finger/pencil is
     */
    private func updatePosition(touch: UITouch) {
        updateLocation(location: touch.location(in: superview!))
    }

    /**
     Update the location of the joystick based on the given touch location. Resulting behavior depends on `movable`
     setting.
     - parameter location: the current handle position. NOTE: in coordinates of the superview
     */
    private func updateLocation(location: CGPoint) {
        guard let superview = self.superview else { return }
        guard superview.bounds.contains(location) else { return }

        let delta = location - frame.mid
        let newDisplacement = delta.magnitude / radius

        // Calculate pointing angle used displacements. NOTE: using this ordering of dx, dy to atan2f to obtain
        // navigation angles where 0 is at top of clock dial and angle values increase in a clock-wise direction.
        //
        let newAngleRadians = atan2f(Float(delta.dx), Float(delta.dy))

        if movable {
            if newDisplacement > 1.0 {
                if repositionBase(location: location, angle: newAngleRadians) {
                    repositionHandle(angle: newAngleRadians)
                }
                else {
                    handleImageView.center = bounds.mid + delta
                }
            }
            else {
                handleImageView.center = bounds.mid + delta
            }
        }
        else if newDisplacement > 1.0 {
            repositionHandle(angle: newAngleRadians)
        }
        else {
            handleImageView.center = bounds.mid + delta
        }

        reportPosition(angleRadians: newAngleRadians, displacement: min(newDisplacement, 1.0))
    }

    /**
     Report the current joystick values to any registered `monitor`.
    
     - parameter angleRadians: the current angle of the joystick handle
     - parameter displacement: the current displacement of the joystick handle
     */
    private func reportPosition(angleRadians: Float, displacement: CGFloat) {
        if displacement != self.displacement || angleRadians != self.lastAngleRadians {
            self.displacement = displacement
            self.lastAngleRadians = angleRadians
            monitor?(self.angle, displacement)
        }
    }
    
    /**
     Move the base so that the handle displacement is <= 1.0 from the base. THe last step of this operation is
     a clamping of the base origin so that it stays within a configured boundary. Such clamping can result in
     a joystick handle whose displacement is > 1.0 from the base, so the caller should account for that by looking
     for a `true` return value.
    
     - parameter location: the current joystick handle center position
     - parameter angle: the angle the handle makes with the center of the base
     - returns: true if the base cannot move sufficiently to keep the displacement of the handle <= 1.0
     */
    private func repositionBase(location: CGPoint, angle: Float) -> Bool {
        if originalCenter == nil {
            originalCenter = center
        }
        
        // Calculate point that should be on the circumference of the base image.
        //
        let end = CGVector(dx: CGFloat(sinf(angle)) * radius, dy: CGFloat(cosf(angle)) * radius)

        // Calculate the origin of our frame, working backwards from the given location, and move to it.
        //
        let origin = location - end - frame.size / 2.0

        frame.origin = self.originClamper(origin)
        return frame.origin != origin
    }

    /**
     Move the joystick handle so that the angle made up of the triangle from the base 12:00 position on its circumference, the base center,
     and the joystick center is the given value.
    
     - parameter angle: the angle (radians) to conform to
     */
    private func repositionHandle(angle: Float) {

        // Keep handle on the circumference of the base image
        //
        let x = CGFloat(sinf(angle)) * radius
        let y = CGFloat(cosf(angle)) * radius
        handleImageView.frame.origin = CGPoint(x: x + bounds.midX - handleImageView.bounds.size.width / 2.0,
                                               y: y + bounds.midY - handleImageView.bounds.size.height / 2.0)
    }
}
