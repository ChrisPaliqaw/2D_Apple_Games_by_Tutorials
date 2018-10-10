import Foundation
import CoreGraphics

public func delay(seconds: TimeInterval,
                  completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds,
                                  execute: completion)
}
