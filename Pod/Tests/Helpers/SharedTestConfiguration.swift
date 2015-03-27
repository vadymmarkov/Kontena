import Quick
import Nimble

class SharedTestConfiguration: QuickConfiguration
{
    override class func configure(configuration: Configuration)
    {
        sharedExamples("binder") { (sharedExampleContext: SharedExampleContext) in
            it("creates definition") {
                let definitions: [String: Definition] = sharedExampleContext()["definitions"] as! [String: Definition]
                expect(definitions.count).to(equal(1))

                let key: String = sharedExampleContext()["key"] as! String
                let initialInstance: AnyObject? = sharedExampleContext()["initialInstance"]
                let value = definitions[key]
                expect(value).notTo(beNil())

                if value?.scope == Definition.Scope.Singleton {
                    expect(value?.instance).to(beIdenticalTo(initialInstance))
                } else {
                    expect(value?.instance).notTo(beIdenticalTo(initialInstance))
                }
            }
        }

        sharedExamples("singleton definition") { (sharedExampleContext: SharedExampleContext) in
            it("returns the same instance") {
                let definition: Definition = sharedExampleContext()["definition"] as! Definition
                let instance1: AnyObject? = definition.instance
                let instance2: AnyObject? = definition.instance

                expect(definition.instance).notTo(beNil())
                expect(instance1).to(beIdenticalTo(instance2))
            }
        }

        sharedExamples("prototype definition") { (sharedExampleContext: SharedExampleContext) in
            it("returns the unique instance") {
                let definition: Definition = sharedExampleContext()["definition"] as! Definition
                let instance1: AnyObject? = definition.instance
                let instance2: AnyObject? = definition.instance

                expect(definition.instance).notTo(beNil())
                expect(instance1).notTo(beIdenticalTo(instance2))
            }
        }
    }
}
