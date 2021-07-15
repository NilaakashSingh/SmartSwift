import UIKit
import Foundation

/// Concurrent for loop
func work() {
    let firstStartDate = Date()
    Array(1...1000).forEach { _ = (0...$0).reduce(0, +) }
    let firstEndDate = Date()

    let secondStartDate = Date()
    /// This is for variable which will not have global scope
    Array(1...1000).parallelForEach { _ = (0...$0).reduce(0, +) }
    let secondEndDate = Date()
    
    print(firstEndDate.timeIntervalSince(firstStartDate))
    print(secondEndDate.timeIntervalSince(secondStartDate))
}

// Parallel for each
extension Array {
    
    /// This should only be used if number of iterations is atleast three times number of cores available in device
    /// For eg for 3 cores your array iterations should be more than 9
    func parallelForEach(_ body: (Element) -> Void) {
        DispatchQueue.concurrentPerform(iterations: count) { index in
            body(self[index])
        }
    }
}
    
work()
