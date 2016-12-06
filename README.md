# Joystick

![](animation.gif)

A custom UIView in Swift that presents a simple joystick interface. The custom view consists of two UIImageView
instances, one for the base and one for the handle. Moving the handle generates two values

* angle — the direction the handle is point, given in degrees, where north/up is 0° and east/right is 90°
* displacement — the distance from the center the handle moved, from 0.0 to 1.0 with 1.0.

The view supports an option (`movable`) where the view will move when the user moves the handle to a
displacement beyond 1.0. This can be useful when the initial position of the joystick in an app is not ideal for
the user's thumb. Double-tapping on the joystick moves it back to its original position.

In the animation above, there are two joysticks, one green and one red. The green is *fixed* and does not move
even when the touch motion would cause a displacement larger than 1.0. The yello joystick however is *movable*,
with the base following the touch motion. Base motion is optionally restricted to a `CGRect`, as is the case in
the demonstration animation above.

# Code

The Xcode playground code sets up the display environemnt and installs two joysticks, one that is fixed (green)
and the other that is movable (red). Both joysticks report out their positions in two labels, one for angles and
the other for displacement.

The [JoyStickView.swift](./Joystick.playground/Sources/JoyStickView.swift) file that defines the joystick view
and behavior resides inside the playground in the [Sources](./Joystick.playground/Sources) directory inside of
the playground package. There is also a file there
([CoreGraphics+Additions.swift](./Joystick.playground/Sources/CoreGraphics+Additions.swift)) that contains
various extensions to some CoreGraphics structs that allow for some simplified mathematical expressions in the
joystick code.

The `JoyStickView.swift` depends on two image assets found in the [Resources](./Joystick.playground/Resources)
folder:

* JoyStickBase\*.png — the image to use for the base of the joystick
* JoyStickHandle\*.png — the image to use for the handle of the joystick. **Note**: this will bec tinted with
  the `handleTintColor` setting (defaults to the view's `tintColor` parameter)

Both exist in three resolutions for the various iOS devices out today. They were generated using the great
[Opacity](http://likethought.com/opacity/) app. The Opacity documents are included in this repository at
the top-level ([JoyStickBase.opacity](./JoyStickBase.opacity) and
[JoyStickHandle.opacity](./JoyStickHandle.opacity))
