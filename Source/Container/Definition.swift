import Foundation

public class Definition
{
    public enum Scope
    {
        case Singleton
        case Prototype
    }

    public var scope: Scope

    private let factory: () -> AnyObject
    private var object: AnyObject?

    public var instance: AnyObject?
    {
        if object == nil || scope == Scope.Prototype {
            object = factory()
        }

        return object
    }

    public init(factory: () -> AnyObject, scope: Scope = Scope.Prototype)
    {
        self.factory = factory
        self.scope = scope
    }

    public func asSingleton()
    {
        scope = Scope.Singleton
    }

    public func asPrototype()
    {
        scope = Scope.Prototype
    }
}
