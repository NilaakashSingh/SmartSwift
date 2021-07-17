import UIKit
import Foundation

// MARK: - Concurrent for loop
/* Concurrent for loop */
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

// MARK: - Mirror API
/* Mirror API */
class SDK1 {
    func start() {
        print("Initialising SDK1")
    }
}

class SDK2 {
    func start() {
        print("Initialising SDK2")
    }
}

class SDK3 {
    func start() {
        print("Initialising SDK3")
    }
}

// This can be replaced by
protocol BaseSDK {
    func configure()
}

extension SDK1: BaseSDK {
    func configure() {
         start()
    }
}

extension SDK2: BaseSDK {
    func configure() {
         start()
    }
}

extension SDK3: BaseSDK {
    func configure() {
         start()
    }
}

class ConfigureClass {
    let abc = SDK1()
    let xyz = SDK2()
    let wer = SDK3()
    
    func configureManally() {
        abc.start()
        xyz.start()
        wer.start()
    }
    
    func configureWithMirror() {
        for child in Mirror(reflecting: self).children {
            if let configurableChild = child as? BaseSDK {
                configurableChild.configure()
            }
        }
    }
}


ConfigureClass().configureManally()
ConfigureClass().configureWithMirror()

// MARK: - Enum with associate types
/* Enum with associate types */

enum NewProfessionType {
    case error1(id: String, code: Int, description: String)
    case error2(id: Int, newcode: Int, differentDescription: String)
    
    var description: String {
        switch self {
        case .error1(_, _ , let description),
                .error2(_, _, let description):
            return description
        }
    }
}

let abc = NewProfessionType.error2(id: 1,
                                   newcode: 1,
                                   differentDescription: "abc")

// Two ways of accessing it
// 1st
print(abc.description)

// 2nd
if case let NewProfessionType.error2(id,
                                     newcode,
                                     differentDescription) = abc {
    print(differentDescription)
}
    
