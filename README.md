# Joystick

![](animation.gif)

A custom UIView in Swift that presents a simple joystick interface. The custom view consists of two UIImageView
instances, one for the base and one for the handle. Moving the handle generates two values

* angle — the direction the handle is point, given in degrees, where north/up is 0° and east/right is 90°
* displacement — the distance from the center the handle moved, from 0.0 to 1.0 with 1.0.

The view supports an option (`movable`) where the view will move when the user moves the handle to a
displacement beyond 1.0. This can be useful when the initial position of the joystick in an app is not ideal for
the user's thumb.
