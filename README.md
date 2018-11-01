[![Build
Status](https://travis-ci.org/bradhowes/Joystick.svg?branch=master)](https://travis-ci.org/bradhowes/Joystick)
[![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Joystick

![](https://github.com/bradhowes/Joystick/blob/master/animation.gif?raw=true)

A custom UIView in Swift that presents a simple joystick interface. The custom view consists of two UIImageView
instances, one for the base and one for the handle. Moving the handle generates two values

* angle — the direction the handle is point, given in degrees, where north/up is 0° and east/right is 90°
* displacement — the distance from the center the handle moved, from 0.0 to 1.0 with 1.0.

The view supports an option (`movable`) where the view will move when the user moves the handle to a
displacement beyond 1.0. This can be useful when the initial position of the joystick in an app is not ideal for
the user's thumb. Double-tapping on the joystick moves it back to its original position.

In the animation above, there are two joysticks, one green and one magenta. The green is *fixed* and does not
move even when the touch motion would cause a displacement larger than 1.0. The magenta joystick however is
*movable*, with the base following the touch motion. For movable joysticks, the Base motion is optionally
restricted to a `CGRect`, as is the case in the demonstration animation above where the magenta joystick cannot
move out of the red band.

# Code

The Xcode workspace contains three components:

- a framework called [JoyStickView](https://github.com/bradhowes/Joystick/tree/master/JoyStickView)
- a simple iOS application called [JoyStickViewApp](https://github.com/bradhowes/Joystick/tree/master/JoyStickViewApp)
- a playground called [JoyStickView Playground](https://github.com/bradhowes/Joystick/tree/master/JoyStickView%20Playground.playground/Contents.swift)

Both the playground and the app rely on the framework for the JoyStickView UIView.

The Xcode playground code sets up the display environemnt and installs two joysticks, one that is fixed (green)
and the other that is movable (yellow). Both joysticks report out their positions in two labels, one for angles and
the other for displacement.

The [JoyStickView.swift](https://github.com/bradhowes/Joystick/tree/master/JoyStickView/Src/JoyStickView.swift)
file defines the joystick view and behavior. It resides inside the [JoyStickView
framework](https://github.com/bradhowes/Joystick/tree/master/JoyStickView). There you will also find a file
called
[CoreGraphics+Additions.swift](https://github.com/bradhowes/Joystick/tree/master/JoyStickView/Src/CoreGraphics+Additions.swift)
that contains various extensions to some CoreGraphics structs that allow for some simplified mathematical
expressions in the [JoyStickView](https://github.com/bradhowes/Joystick) code.

By default the
[JoyStickView](https://github.com/bradhowes/Joystick/tree/master/JoyStickView/Src/JoyStickView.swift) class uses
two image assets found in the [Images](https://github.com/bradhowes/Joystick/tree/master/JoyStickView/Images)
folder:

* JoyStickBase\*.png — the image to use for the base of the joystick
* JoyStickHandle\*.png — the image to use for the handle of the joystick. **Note**: this will be tinted with the
  `handleTintColor` setting

Both exist in three resolutions for the various iOS devices out today. They were generated using the great
[Opacity](http://likethought.com/opacity/) app. The Opacity documents are included in this repository in the
[Resources](https://github.com/bradhowes/Joystick/tree/master/JoyStickView/Resources) directory.

To use your own images, simple set `baseImage` and/or `handleImage` attributes with the `UIImage` you wish to
use.

# Documentation

Please see the [code documentation](https://bradhowes.github.io/Joystick/index.html) for additional information.

# CocoaPods

There is a simple [CocoaPods[(https://cocoapods.org) spec file available so you can add the code and resources
by adding "BRHJoyStickView" to your `Podfile` file. Currently everything more or less works, except for the fact
that pointing to image resources via Interface Builder (IB) will result in invalid UImage results because the files wont be 
found where IB was able to find them. The only solution is to manually locate those files and set them in your 
view loading code. Something like the following should help:

```
extension Bundle {

    /**
     Locate an inner Bundle generated from CocoaPod packaging.

     - parameter name: the name of the inner resource bundle. This should match the "s.resource_bundle" key or
       one of the "s.resoruce_bundles" keys from the podspec file that defines the CocoPod.
     - returns: the resource Bundle or `self` if resource bundle was not found
    */
    func podResource(name: String) -> Bundle {
        guard let bundleUrl = self.url(forResource: name, withExtension: "bundle") else { return self }
        return Bundle(url: bundleUrl) ?? self
    }
}
```

In your setup code, you then will need to do something like so:

```
    override func viewDidLoad() {
        super.viewDidLoad()
        let bundle = Bundle(for: JoyStickView.self).podResource(name: "BRHJoyStickView")
        joystick.baseImage = UIImage(named: "FancyBase", in: bundle, compatibleWith: nil)
        joystick.handleImage = UIImage(named: "FancyHandle", in: bundle, compatibleWith: nil)
    }
```

The `podResource` method attempts to locate a named inner bundle, defaulting to the original bundle if not found. The
`viewDidLoad` code will then use the right `bundle` object in the UIImage constructors.

