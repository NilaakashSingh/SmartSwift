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
    

// MARK: - Property Wrappers

@propertyWrapper struct Capitalized {
    var wrappedValue: String {
        didSet { wrappedValue = wrappedValue.capitalized }
    }

    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.capitalized
    }
}

struct User {
    @Capitalized var firstName: String
    @Capitalized var lastName: String
}

var user = User(firstName: "Neel", lastName: "Singh")
print(user.firstName)
print(user.lastName)

user.lastName = "Uday"
print(user.lastName)

// MARK: - Dynamic member look up

@dynamicMemberLookup
struct Person {
    subscript(dynamicMember member: String) -> String {
        let properties = ["name": "Abc xyz", "city": "Venice"]
        return properties[member, default: ""]
    }
}

let person = Person()
print(person.name)
print(person.city)


@dynamicMemberLookup
struct NewObject {
    subscript(dynamicMember member: String) -> (_ input: String) -> Void {
        return {
            print("Hello! I live at the address \($0).")
        }
    }
}

let newObject = NewObject()
newObject.printAddress("555 Taylor Swift Avenue")

// Json example of dynamic member lookup
@dynamicMemberLookup
enum JSON {
   case intValue(Int)
   case stringValue(String)
   case arrayValue(Array<JSON>)
   case dictionaryValue(Dictionary<String, JSON>)

   var stringValue: String? {
      if case .stringValue(let str) = self {
         return str
      }
      return nil
   }

   subscript(index: Int) -> JSON? {
      if case .arrayValue(let arr) = self {
         return index < arr.count ? arr[index] : nil
      }
      return nil
   }

   subscript(key: String) -> JSON? {
      if case .dictionaryValue(let dict) = self {
         return dict[key]
      }
      return nil
   }

   subscript(dynamicMember member: String) -> JSON? {
      if case .dictionaryValue(let dict) = self {
         return dict[member]
      }
      return nil
   }
}

let j = JSON.dictionaryValue([
  "comment": .stringValue("Not being able to tell the difference at call site is confusing"),
  "count": .intValue(42),
  "count2": .intValue(1337)
  ])


@dynamicMemberLookup
public struct DynamicLookupContext {
  let value: Any

  public subscript(dynamicMember member: String) -> DynamicLookupContext? {
    let dict = value as? [String: Any]
    guard let value = dict?[member] else { return nil }
    return DynamicLookupContext(value: value)
  }
    
  public subscript(index: Int) -> DynamicLookupContext? {
    guard let array = value as? [Any] else { return nil }
    return DynamicLookupContext(value: array[index])
  }
}

public extension Dictionary where Key == String, Value: Any {
  func dynamicLookup<T>(execute: (DynamicLookupContext) -> DynamicLookupContext?) -> T? {
    let wrapped = DynamicLookupContext(value: self)
    let result = execute(wrapped)
    return result?.value as? T
  }
}

let j2: [String: Any] = [
  "name": "Olivier",
  "address": [
    "street": "Swift Street",
    "number": 1337,
    "city": "PlaygroundVille"
  ]
]

print(j.count ?? 0)
let street2: String? = j2.dynamicLookup { $0.address?.street }
print(street2)


// MARK: - Higher Order Functions
// MARK: - Map and Compact Map
struct Employee {
    var name: String?
    var id: Int
    var earningInDollars: Int
    var age: Int
}

let employee = [Employee(name: "Wakanda", id: 1, earningInDollars: 4000, age: 38),
                Employee(name: "Zimbawe", id: 2, earningInDollars: 3000, age: 20),
                Employee(name: nil, id: 3, earningInDollars: 5000, age: 25)]

var employeeCopy = [Employee(name: "Wakanda", id: 1, earningInDollars: 4000, age: 38),
                Employee(name: "Zimbawe", id: 2, earningInDollars: 3000, age: 20),
                Employee(name: nil, id: 3, earningInDollars: 5000, age: 25)]

let mappedArray = employee.map { $0.name }
let compactMappedArray = employee.compactMap { $0.name }
print(mappedArray)
print(compactMappedArray)

// MARK: - Drop, Remove
// This works when the employee instance is let as well
// Drop doesn't delete the actual array it just skips the index or element
let dropArray = employee.dropFirst()
print(dropArray)

// This works when we have var as employee instance
// Remove actually removes the element from physical memory
let removeArray = employeeCopy.remove(at: 1)
print(removeArray) // This is same
print(employeeCopy) // As this

// MARK: - Reduce

let reducedEarningArray = employee.map { $0.earningInDollars }.reduce(0, { x,y in x + y })
print(reducedEarningArray)
