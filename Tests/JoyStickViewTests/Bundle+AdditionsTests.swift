// Copyright © 2023 Brad Howes. All rights reserved.

import XCTest
import JoyStickView

class BundleAdditionsTests: XCTestCase {

  func testPodResource() {
    let main = Bundle.main
    for bundle in Bundle.allBundles {
      _ = main.podResource(name: bundle.description)
    }
  }
}
