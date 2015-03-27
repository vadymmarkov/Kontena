import Foundation

@objc protocol SomeProtocol
{
    func someMethod() -> String
}

class SomeBaseClass
{
}

class SomeClass: SomeBaseClass, SomeProtocol
{
    var service: SomeService?

    required override init()
    {
        super.init()
    }

    @objc func someMethod() -> String
    {
        return "Nothing"
    }
}

class SomeClass1: NSObject
{
    var name: String?
    var service: SomeService?
    var service1: SomeService1?
}

class SomeService: NSObject
{
    var name: String?
}

class SomeService1: NSObject
{
    var name: String?
    var some: SomeClass1?
}
