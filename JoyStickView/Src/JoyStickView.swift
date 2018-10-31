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
@IBDesignable public final class JoyStickView: UIView {

    /// Holds a function to call when joystick orientation changes
    public var monitor: JoyStickViewMonitor? = nil

    /// The last-reported angle from the joystick handle. Unit is degrees, with 0° up (north) and 90° right (east)
    public var angle: CGFloat { return displacement != 0.0 ? CGFloat(180.0 - angleRadians * 180.0 / Float.pi) : 0.0 }
    
    /// The last-reported displacement from the joystick handle. Dimensionless but is the ratio of movement over
    /// the radius of the joystick base. Always falls between 0.0 and 1.0
    public private(set) var displacement: CGFloat = 0.0
    
    /// If `true` the joystick will move around in the parant's view so that the joystick handle is always at a
    /// displacement of 1.0. This is the default mode of operation. Setting to `false` will keep the view fixed.
    @IBInspectable public var movable: Bool = false

    /// The original location of a movable joystick. Used to restore its position when user double-taps on it.
    public var movableCenter: CGPoint? = nil

    /// Area where the joystick can move
    public var movableBounds: CGRect? {
        didSet {
            switch movableBounds {
            case .some(let mb):
                centerClamper = { CGPoint(x: min(max($0.x, mb.minX), mb.maxX), y: min(max($0.y, mb.minY), mb.maxY)) }
            default:
                centerClamper = { $0 }
            }
        }
    }

    /// The opacity of the base of the joystick. Note that this is different than the view's overall opacity
    /// setting. The end result will be a base image with an opacity of `baseAlpha` * `view.alpha`
    @IBInspectable public var baseAlpha: CGFloat {
        get {
            return baseImageView.alpha
        }
        set {
            baseImageView.alpha = newValue
        }
    }

    /// The opacity of the handle of the joystick. Note that this is different than the view's overall opacity setting.
    /// The end result will be a handle image with an opacity of `handleAlpha` * `view.alpha`
    @IBInspectable public var handleAlpha: CGFloat {
        get {
            return handleImageView.alpha
        }
        set {
            handleImageView.alpha = newValue
        }
    }

    /// The tintColor to apply to the handle. Changing it while joystick is visible will update the handle image.
    @IBInspectable public var handleTintColor: UIColor? = nil {
        didSet { generateHandleImage() }
    }

    /// Scaling factor to apply to the joystick handle. A value of 1.0 will result in no scaling of the image,
    /// however the default value is 0.85 due to historical reasons.
    @IBInspectable public var handleSizeRatio: CGFloat = 0.85 {
        didSet {
            scaleHandleImageView()
        }
    }

    /// Control how the handle image is generated. When this is `false` (default), a CIFilter will be used to tint
    /// the handle image with the `handleTintColor`. This results in a monochrome image of just one color, but with
    /// lighter and darker areas depending on the original image. When this is `true`, the handle image is just
    /// used as a mask, and all pixels with an alpha = 1.0 will be colored with the `handleTintColor` value.
    @IBInspectable public var colorFillHandleImage: Bool = false {
        didSet { generateHandleImage() }
    }

    /// Controls how far the handle can travel along the radius of the base. A value of 1.0 (default) will let the handle travel
    /// the full radius, with maximum travel leaving the center of the handle lying on the circumference of the base. A value
    /// greater than 1.0 will let the handle travel beyond the circumference of the base, while a value less than 1.0 will
    /// reduce the travel to values within the circumference. Note that regardless of this value, handle movements will always
    /// report displacement values between 0.0 and 1.0 inclusive.
    @IBInspectable public var travel: CGFloat = 1.0

    /// The image to use for the base of the joystick
    @IBInspectable public var baseImage: UIImage? {
        didSet { baseImageView.image = baseImage }
    }

    /// The image to use for the joystick handle
    @IBInspectable public var handleImage: UIImage? {
        didSet { generateHandleImage() }
    }

    /// Control whether view will recognize a double-tap gesture and move the joystick base to its original location
    /// when it happens. Note that this is only useful if `moveable` is true.
    @IBInspectable public var enableDoubleTapForFrameReset = true {
        didSet {
            if let dtgr = doubleTapGestureRecognizer {
                removeGestureRecognizer(dtgr)
                doubleTapGestureRecognizer = nil
            }
            if enableDoubleTapForFrameReset {
                installDoubleTapGestureRecognizer()
            }
        }
    }

    /// The max distance the handle may move in any direction, where the start is the center of the joystick base and the end
    /// is on the circumference of the base when travel is 1.0.
    private var radius: CGFloat { return self.bounds.size.width / 2.0 * travel }
    
    /// The image to use to show the base of the joystick
    private var baseImageView: UIImageView = UIImageView(image: nil)

    /// The image to use to show the handle of the joystick
    private var handleImageView: UIImageView = UIImageView(image: nil)

    /// Cache of the last joystick angle in radians
    private var angleRadians: Float = 0.0

    /// Tap gesture recognizer for double-taps which will reset the joystick position
    private var tapGestureRecognizer: UITapGestureRecognizer?

    /// A filter for joystick handle centers. Used to restrict handle movements.
    private var centerClamper: (CGPoint) -> CGPoint = { $0 }

    /// Tap gesture recognizer for detecting double-taps. Only present if `enableDoubleTapForFrameReset` is true
    private var doubleTapGestureRecognizer: UITapGestureRecognizer?
    
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

    public override func layoutSubviews() {
        super.layoutSubviews()
        initialize()
    }
}

// MARK: - Implementation Details

extension JoyStickView {
    
    /**
     Common initialization of view. Creates UIImageView instances for base and handle.
     */
    private func initialize() {
        baseImageView.frame = bounds
        addSubview(baseImageView)

        scaleHandleImageView()
        addSubview(handleImageView)

        let bundle = Bundle(for: JoyStickView.self)

        if self.baseImage == nil {
            if let baseImage = UIImage(named: "DefaultBase", in: bundle, compatibleWith: nil) {
                self.baseImage = baseImage
            }
        }

        baseImageView.image = baseImage

        if self.handleImage == nil {
            if let handleImage = UIImage(named: "DefaultHandle", in: bundle, compatibleWith: nil) {
                self.handleImage = handleImage
            }
        }
        
        generateHandleImage()

        if enableDoubleTapForFrameReset {
            installDoubleTapGestureRecognizer()
        }
    }

    private func scaleHandleImageView() {
        let inset = (1.0 - handleSizeRatio) * bounds.width
        handleImageView.frame = bounds.insetBy(dx: inset, dy: inset)
    }
    
    /**
     Install a UITapGestureRecognizer to detect and process double-tap activity on the joystick.
     */
    private func installDoubleTapGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resetFrame))
        tapGestureRecognizer!.numberOfTapsRequired = 2
        addGestureRecognizer(tapGestureRecognizer!)
    }

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
        reportPosition(angleRadians: 0.0, displacement: 0.0)
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
            if newDisplacement > 1.0 && repositionBase(location: location, angle: newAngleRadians) {
                repositionHandle(angle: newAngleRadians)
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
        if displacement != self.displacement || angleRadians != self.angleRadians {
            self.displacement = displacement
            self.angleRadians = angleRadians
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
     - returns: true if the base **cannot** move sufficiently to keep the displacement of the handle <= 1.0
     */
    private func repositionBase(location: CGPoint, angle: Float) -> Bool {
        if movableCenter == nil {
            movableCenter = self.center
        }

        // Calculate point that should be on the circumference of the base image.
        //
        let end = CGVector(dx: CGFloat(sinf(angle)) * radius, dy: CGFloat(cosf(angle)) * radius)

        // Calculate the origin of our frame, working backwards from the given location, and move to it.
        //
        let desiredCenter = location - end //  - frame.size / 2.0
        self.center = centerClamper(desiredCenter)
        return self.center != desiredCenter
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

extension JoyStickView {

    public override func prepareForInterfaceBuilder() {
        print("hi mom!")
        print(baseImageView)
        print(baseImage ?? "nil")
        print(handleImageView)
        print(handleImage ?? "nil")
    }
    
}
