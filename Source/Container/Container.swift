import Foundation
import TypeHelper

public protocol Binder
{
    func bind<T: AnyObject>(instance: T)

    func bind<T: AnyObject>(instance: T, toType type: T.Type)

    func bind<T: AnyObject>(instance: T, toKey key: String)

    func bindFactory<T: AnyObject>(factory: () -> T) -> Definition

    func bindFactory<T: AnyObject>(factory: () -> T, toType type: T.Type) -> Definition

    func bindFactory<T: AnyObject>(factory: () -> T, toKey key: String) -> Definition
}

public protocol Resolver
{
    func resolveType<T: AnyObject>(type: T.Type) -> T?

    func resolveKey(key: String) -> AnyObject?
}

public class Container: Binder, Resolver
{
    var definitions: [String: Definition] = [:]

    public var resolveDependencies: Bool = false

    public class var sharedInstance: Container
    {
        struct Static {
            static let instance: Container = Container()
        }
        return Static.instance
    }

    // MARK: - Container

    public func mergeWithContainer(container: Container) -> Container
    {
        for (k, v) in container.definitions {
            definitions.updateValue(v, forKey: k)
        }

        return self
    }

    public func clear()
    {
        definitions.removeAll(keepCapacity: false)
    }

    // MARK: - Binder

    public func bind<T: AnyObject>(instance: T)
    {
        let key = nonOptionalTypeName(T.self)
        bind(instance, toKey: key)
    }

    public func bind<T: AnyObject>(instance: T, toType type: T.Type)
    {
        let key = nonOptionalTypeName(type)
        bind(instance, toKey: key)
    }

    public func bind<T: AnyObject>(instance: T, toKey key: String)
    {
        bindFactory({
            () -> T in
            return instance
        }, toKey:key).asSingleton()
    }

    public func bindFactory<T: AnyObject>(factory: () -> T) -> Definition
    {
        let key = nonOptionalTypeName(T.self)
        return bindFactory(factory, toKey: key)
    }

    public func bindFactory<T: AnyObject>(factory: () -> T, toType type: T.Type) -> Definition
    {
        let key = nonOptionalTypeName(type)
        return bindFactory(factory, toKey: key)
    }

    public func bindFactory<T: AnyObject>(factory: () -> T, toKey key: String) -> Definition
    {
        var definitionFactory: () -> T = factory
        if resolveDependencies {
            definitionFactory = {
                () -> T in
                return self.resolveInstance(factory(), withDependency: nil)
            }
        }
        let definition = Definition(factory: definitionFactory)
        definitions[key] = definition
        return definition
    }

    // MARK: - Resolver

    public func resolveType<T: AnyObject>(type: T.Type) -> T?
    {
        let key = nonOptionalTypeName(type)
        return resolveKey(key) as? T
    }

    public func resolveKey(key: String) -> AnyObject?
    {
        if let definition = definitions[key] {
            if let instance: AnyObject = definition.instance {
                return instance
            }
        }

        return nil
    }

    // MARK: - Auto resolve

    func resolveInstance<T: AnyObject>(instance: T, withDependency dependency: (key: String, instance: AnyObject)?) -> T
    {
        if instance is NSObject {
            let mirror = reflect(instance)
            let key = nonOptionalTypeName(T.self)

            for var i = 0; i < mirror.count; i++ {
                let (propertyName, childMirror) = mirror[i]

                if childMirror.value as Any? == nil || propertyName == "super" {
                    continue
                }

                var childValue: AnyObject?
                let childKey = nonOptionalTypeName(childMirror.valueType)

                if let dp = dependency {
                    if childKey == dp.key {
                        childValue = dp.instance
                    }
                }

                if childValue == nil {
                    if let childObject: AnyObject = resolveKey(childKey) {
                        childValue = resolveInstance(childObject, withDependency: (key, instance))
                    }
                }

                if let propertyValue: AnyObject = childValue {
                    (instance as! NSObject).setValue(propertyValue, forKey: propertyName)
                }
            }
        }

        return instance
    }
}
