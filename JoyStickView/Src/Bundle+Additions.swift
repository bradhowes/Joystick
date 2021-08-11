// Copyright © 2020 Brad Howes. All rights reserved.

import Foundation

extension Bundle {

    /**
     Locate an inner Bundle generated from CocoaPod packaging.
     
     - parameter name: the name of the inner resource bundle. This should match the "s.resource_bundle" key or
     one of the "s.resource_bundles" keys from the podspec file that defines the CocoPod.
     - returns: the resource Bundle or `self` if resource bundle was not found
     */
    func podResource(name: String) -> Bundle {
        guard let bundleUrl = self.url(forResource: name, withExtension: "bundle") else { return self }
        return Bundle(url: bundleUrl) ?? self
    }
}
