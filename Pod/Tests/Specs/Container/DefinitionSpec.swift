import Foundation
import Quick
import Nimble

class DefinitionSpec: QuickSpec
{
    override func spec()
    {
        describe("Definition") {
            var definition: Definition!

            context("when it has singleton scope") {
                beforeEach {
                    definition = DefinitionFactory.singletonDefinition
                }

                describe("#init") {
                    it("sets properties properly") {
                        expect(definition).notTo(beNil())
                        expect(definition.scope).to(equal(Definition.Scope.Singleton))
                    }
                }

                describe("#instance") {
                    itBehavesLike("singleton definition") {["definition": definition]}
                }
            }

            context("when it has prototype scope") {
                beforeEach {
                    definition = DefinitionFactory.prototypeDefinition
                }

                describe("#init") {
                    it("sets properties properly") {
                        expect(definition).notTo(beNil())
                        expect(definition.scope).to(equal(Definition.Scope.Prototype))
                    }
                }

                describe("#instance") {
                    itBehavesLike("prototype definition") {["definition": definition]}
                }
            }

            describe("#asSingleton") {
                beforeEach {
                    definition = DefinitionFactory.prototypeDefinition
                    definition.asSingleton()
                }

                it("changes scope to singleton") {
                    expect(definition.scope).to(equal(Definition.Scope.Singleton))
                }

                itBehavesLike("singleton definition") {["definition": definition]}
            }

            describe("#asSingleton") {
                beforeEach {
                    definition = DefinitionFactory.singletonDefinition
                    definition.asPrototype()
                }

                it("changes scope to prototype") {
                    expect(definition.scope).to(equal(Definition.Scope.Prototype))
                }

                itBehavesLike("singleton definition") {["definition": definition]}
            }
        }
    }
}
