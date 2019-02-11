import UIKit
import JoyStickView

var str = "Hello, playground"

let xy = [(0.0, 1.0), (1.0, 1.0), (1.0, 0.0), (1.0, -1.0), (0.0, -1.0), (-1.0, -1.0), (-1.0, 0.0), (-1.0, 1.0)]

for pair in xy {
    let rads = atan2(pair.0, -pair.1)
    let degs = 180.0 - rads * 180.0 / .pi
    print("\(pair) - \(rads) \(degs)")
}
