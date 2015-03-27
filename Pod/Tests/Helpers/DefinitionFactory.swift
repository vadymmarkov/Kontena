import Foundation

class DefinitionFactory
{
    class var singletonDefinition: Definition {
        let factory = {
            () -> SomeClass in
            return SomeClass()
        }
        return Definition(factory: factory, scope: Definition.Scope.Singleton)
    }

    class var prototypeDefinition: Definition {
        let factory = {
            () -> SomeClass in
            return SomeClass()
        }
        return Definition(factory: factory)
    }
}
