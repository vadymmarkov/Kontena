import Foundation
import Quick
import Nimble
import TypeHelper

class ContainerSpec: QuickSpec
{
    override func spec()
    {
        describe("Container") {
            var container: Container!

            beforeEach {
                container = Container()
            }

            describe("#sharedInstance") {
                it("is initialized") {
                    expect(Container.sharedInstance).notTo(beNil())
                }

                it("is the same") {
                    expect(Container.sharedInstance).to(beIdenticalTo(Container.sharedInstance))
                }

                it("is separate from unique instance") {
                    expect(Container.sharedInstance).notTo(beIdenticalTo(Container()))
                }
            }

            describe("#init") {
                it("creates unique instances") {
                    expect(Container()).notTo(beIdenticalTo(Container()))
                }

                it("creates empty dictionary for definitions") {
                    expect(container.definitions).notTo(beNil())
                    expect(container.definitions.count).to(equal(0))
                }
            }

            describe("#mergeWithContainer") {
                var instance1: Definition!
                var instance2: Definition!

                beforeEach {
                    instance1 = DefinitionFactory.singletonDefinition
                    instance2 = DefinitionFactory.singletonDefinition

                    container.definitions["test1"] = instance1
                }

                it("adds new items to the dictionary of definitions") {
                    var container2 = Container()
                    container2.definitions["test2"] = instance2

                    expect(container.definitions.count).to(equal(1))

                    container.mergeWithContainer(container2)
                    expect(container.definitions.count).to(equal(2))

                    expect(container.definitions["test1"]).notTo(beNil())
                    expect(container.definitions["test1"]).to(beIdenticalTo(instance1))

                    expect(container.definitions["test2"]).notTo(beNil())
                    expect(container.definitions["test2"]).to(beIdenticalTo(instance2))
                }

                it("updates old items with new ones") {
                    var container2 = Container()
                    container2.definitions["test1"] = instance2

                    expect(container.definitions.count).to(equal(1))

                    container.mergeWithContainer(container2)
                    expect(container.definitions.count).to(equal(1))
                    expect(container.definitions["test1"]).to(beIdenticalTo(instance2))
                }
            }

            describe("#clear") {
                beforeEach {
                    container.definitions["test1"] = DefinitionFactory.singletonDefinition
                    container.definitions["test2"] = DefinitionFactory.singletonDefinition
                }

                it("removes all items from dictionary of bindings") {
                    expect(container.definitions.count).to(equal(2))
                    container.clear()
                    expect(container.definitions.count).to(equal(0))
                }
            }

            context("binder") {
                describe("#bind") {
                    var instance: SomeClass!

                    beforeEach {
                        container.clear()
                        instance = SomeClass()
                        container.bind(instance)
                    }

                    it("updates definition") {
                        expect(container.definitions.count).to(equal(1))
                        container.bind(instance)
                        expect(container.definitions.count).to(equal(1))
                    }

                    itBehavesLike("binder") {["definitions": container.definitions,
                        "key": nonOptionalTypeName(SomeClass.self),
                        "initialInstance": instance]
                    }
                }

                describe("#bind:toType") {
                    context("when it's the class of the instance") {
                        var instance: SomeClass!

                        beforeEach {
                            container.clear()
                            instance = SomeClass()
                            container.bind(instance, toType: SomeClass.self)
                        }

                        it("updates definition") {
                            expect(container.definitions.count).to(equal(1))
                            container.bind(instance, toType: SomeClass.self)
                            expect(container.definitions.count).to(equal(1))
                        }

                        itBehavesLike("binder") {["definitions": container.definitions,
                            "key": nonOptionalTypeName(SomeClass.self),
                            "initialInstance": instance]
                        }
                    }

                    context("when it's the class of the parent") {
                        var instance: SomeBaseClass!

                        beforeEach {
                            container.clear()
                            instance = SomeClass()
                            container.bind(instance, toType: SomeBaseClass.self)
                        }

                        it("not overrides definition of the instance class") {
                            let instance2 = SomeClass()
                            container.bind(instance2, toType: SomeClass.self)
                            expect(container.definitions.count).to(equal(2))
                        }

                        it("updates definition") {
                            expect(container.definitions.count).to(equal(1))
                            container.bind(instance, toType: SomeBaseClass.self)
                            expect(container.definitions.count).to(equal(1))
                        }

                        itBehavesLike("binder") {["definitions": container.definitions,
                            "key": nonOptionalTypeName(SomeBaseClass.self),
                            "initialInstance": instance]
                        }
                    }

                    context("when it's the protocol") {
                        var instance: SomeProtocol!

                        beforeEach {
                            container.clear()
                            instance = SomeClass()
                            container.bind(instance, toType: SomeProtocol.self)
                        }

                        it("not overrides definition of the instance class") {
                            let instance2 = SomeClass()
                            container.bind(instance2, toType: SomeClass.self)
                            expect(container.definitions.count).to(equal(2))
                        }

                        it("updates definition") {
                            expect(container.definitions.count).to(equal(1))
                            container.bind(instance, toType: SomeProtocol.self)
                            expect(container.definitions.count).to(equal(1))
                        }

                        itBehavesLike("binder") {["definitions": container.definitions,
                            "key": nonOptionalTypeName(SomeProtocol.self),
                            "initialInstance": instance]
                        }
                    }
                }

                describe("#bind:toKey") {
                    var instance: SomeClass!

                    beforeEach {
                        container.clear()
                        instance = SomeClass()
                        container.bind(instance, toKey: "awesome")
                    }

                    it("updates definition") {
                        expect(container.definitions.count).to(equal(1))
                        container.bind(instance, toKey: "awesome")
                        expect(container.definitions.count).to(equal(1))
                    }

                    itBehavesLike("binder") {["definitions": container.definitions,
                        "key": "awesome",
                        "initialInstance": instance]
                    }
                }

                describe("#bindFactory") {
                    let factory = {
                        () -> SomeClass in
                        let i = SomeClass()
                        i.service = nil
                        return SomeClass()
                    }

                    beforeEach {
                        container.clear()
                        container.bindFactory(factory)
                    }

                    it("updates definition") {
                        expect(container.definitions.count).to(equal(1))
                        container.bindFactory(factory)
                        expect(container.definitions.count).to(equal(1))
                    }

                    itBehavesLike("binder") {["definitions": container.definitions,
                        "key": nonOptionalTypeName(SomeClass.self),
                        "initialInstance": factory()]
                    }
                }

                describe("#bindFactory:toType") {
                    let factory = {
                        () -> SomeClass in
                        return SomeClass()
                    }

                    context("when it's the class of the instance") {
                        beforeEach {
                            container.clear()
                            container.bindFactory(factory, toType: SomeClass.self)
                        }

                        it("updates definition") {
                            expect(container.definitions.count).to(equal(1))
                            container.bindFactory(factory, toType: SomeClass.self)
                            expect(container.definitions.count).to(equal(1))
                        }

                        itBehavesLike("binder") {["definitions": container.definitions,
                            "key": nonOptionalTypeName(SomeClass.self),
                            "initialInstance": factory()]
                        }
                    }

                    context("when it's the class of the parent") {
                        beforeEach {
                            container.clear()
                            container.bindFactory(factory, toType: SomeBaseClass.self)
                        }

                        it("not overrides definition of the instance class") {
                            let factory2 = {
                                () -> SomeClass in
                                return SomeClass()
                            }
                            container.bindFactory(factory2, toType: SomeClass.self)
                            expect(container.definitions.count).to(equal(2))
                        }

                        it("updates definition") {
                            expect(container.definitions.count).to(equal(1))
                            container.bindFactory(factory, toType: SomeBaseClass.self)
                            expect(container.definitions.count).to(equal(1))
                            container.bind(SomeClass(), toType: SomeBaseClass.self)
                            expect(container.definitions.count).to(equal(1))
                        }

                        itBehavesLike("binder") {["definitions": container.definitions,
                            "key": nonOptionalTypeName(SomeBaseClass.self),
                            "initialInstance": factory()]
                        }
                    }

                    context("when it's the protocol") {
                        beforeEach {
                            container.clear()
                            container.bindFactory(factory, toType: SomeProtocol.self)
                        }

                        it("not overrides definition of the instance class") {
                            let instance2 = SomeClass()
                            container.bind(instance2, toType: SomeClass.self)
                            expect(container.definitions.count).to(equal(2))
                        }

                        it("updates definition") {
                            expect(container.definitions.count).to(equal(1))
                            container.bindFactory(factory, toType: SomeProtocol.self)
                            expect(container.definitions.count).to(equal(1))
                            container.bind(SomeClass(), toType: SomeProtocol.self)
                            expect(container.definitions.count).to(equal(1))
                        }

                        itBehavesLike("binder") {["definitions": container.definitions,
                            "key": nonOptionalTypeName(SomeProtocol.self),
                            "initialInstance": factory()]
                        }
                    }
                }

                describe("#bindFactory:toKey") {
                    let factory = {
                        () -> SomeClass in
                        return SomeClass()
                    }

                    beforeEach {
                        container.clear()
                        container.bindFactory(factory, toKey: "awesome")
                    }

                    it("updates definition") {
                        expect(container.definitions.count).to(equal(1))
                        container.bindFactory(factory, toKey: "awesome")
                        expect(container.definitions.count).to(equal(1))
                        container.bind(SomeClass(), toKey: "awesome")
                        expect(container.definitions.count).to(equal(1))
                    }

                    itBehavesLike("binder") {["definitions": container.definitions,
                        "key": "awesome",
                        "initialInstance": factory()]
                    }
                }
            }

            context("resolver") {
                describe("#resolveType") {
                    context("when the instance was binded") {
                        var instance = SomeClass()

                        context("when it's the class of the instance") {
                            var resolvedInstance: SomeClass?

                            beforeEach {
                                container.clear()
                                container.bind(instance, toType: SomeClass.self)
                                resolvedInstance = container.resolveType(SomeClass.self)
                            }

                            it("resolves correctly") {
                                expect(resolvedInstance).notTo(beNil())
                                expect(instance).to(beIdenticalTo(resolvedInstance))
                            }
                        }

                        context("when it's the class of the parent") {
                            var resolvedInstance: SomeBaseClass?

                            beforeEach {
                                container.clear()
                                container.bind(instance, toType: SomeBaseClass.self)
                                resolvedInstance = container.resolveType(SomeBaseClass.self)
                            }

                            it("resolves correctly") {
                                expect(resolvedInstance).notTo(beNil())
                                expect(instance).to(beIdenticalTo(resolvedInstance))
                            }
                        }
                    }

                    context("when the factory was binded") {
                        let factory = {
                            () -> SomeClass in
                            return SomeClass()
                        }

                        context("when it's the class of the instance") {
                            var instance: SomeClass!
                            var resolvedInstance: SomeClass?

                            beforeEach {
                                instance = factory()
                                container.clear()
                                container.bindFactory(factory, toType: SomeClass.self)
                                resolvedInstance = container.resolveType(SomeClass.self)
                            }

                            it("resolves correctly") {
                                expect(resolvedInstance).notTo(beNil())
                                expect(instance).notTo(beIdenticalTo(resolvedInstance))
                            }
                        }

                        context("when it's the class of the parent") {
                            var instance: SomeBaseClass!
                            var resolvedInstance: SomeBaseClass?

                            beforeEach {
                                instance = factory()
                                container.clear()
                                container.bindFactory(factory, toType: SomeBaseClass.self)
                                resolvedInstance = container.resolveType(SomeBaseClass.self)
                            }

                            it("resolves correctly") {
                                expect(resolvedInstance).notTo(beNil())
                                expect(instance).notTo(beIdenticalTo(resolvedInstance))
                            }
                        }
                    }

                    context("when no instance/factory was binded") {
                        var resolvedInstance: SomeBaseClass?

                        beforeEach {
                            container.clear()
                            resolvedInstance = container.resolveType(SomeBaseClass.self)
                        }

                        it("resolves correctly") {
                            expect(resolvedInstance).to(beNil())
                        }
                    }
                }

                describe("#resolveKey") {
                    var resolvedInstance: AnyObject?
                    var instance: SomeClass!

                    context("when the instance was binded") {
                        beforeEach {
                            container.clear()
                            instance = SomeClass()

                            let key = "awesome"
                            container.bind(instance, toKey: key)
                            resolvedInstance = container.resolveKey(key)
                        }

                        it("resolves correctly") {
                            expect(resolvedInstance).notTo(beNil())
                            expect(instance).to(beIdenticalTo(resolvedInstance))
                        }
                    }

                    context("when the factory was binded") {
                        let factory = {
                            () -> SomeClass in
                            return SomeClass()
                        }

                        beforeEach {
                            container.clear()
                            instance = factory()

                            let key = "awesome"
                            container.bindFactory(factory, toKey: key)
                            resolvedInstance = container.resolveKey(key)
                        }

                        it("resolves correctly") {
                            expect(resolvedInstance).notTo(beNil())
                            expect(instance).notTo(beIdenticalTo(resolvedInstance))
                        }
                    }

                    context("when no instance/factory was binded") {
                        beforeEach {
                            container.clear()

                            let key = "awesome"
                            resolvedInstance = container.resolveKey(key)
                        }

                        it("resolves correctly") {
                            expect(resolvedInstance).to(beNil())
                        }
                    }
                }

                describe("#resolveInstance:withDependency") {
                    context("when we have one-directional dependency") {
                        var instance: SomeClass1!
                        var service: SomeService!

                        beforeEach {
                            instance = SomeClass1()
                            instance.name = "Some"
                            service = SomeService()
                            service.name = "Service"

                            container.clear()
                            container.bind(instance)
                            container.bind(service)
                        }

                        it("auto resolves correctly") {
                            var some = container.bindFromMirror(reflect(instance), toInstance: instance, withDependency: nil)
                            expect(some).notTo(beNil())
                            expect(some).to(beIdenticalTo(instance))
                            expect(some.name).to(equal("Some"))
                            expect(some.service).notTo(beNil())
                            expect(some.service).to(beIdenticalTo(service))
                            expect(some.service?.name).to(equal("Service"))
                        }
                    }

                    context("when we have two-directional dependency") {
                        var instance: SomeClass1!
                        var service: SomeService1!

                        beforeEach {
                            instance = SomeClass1()
                            instance.name = "Some"
                            service = SomeService1()
                            service.name = "Service"

                            container.clear()
                            container.bind(instance)
                            container.bind(service)
                        }

                        it("auto resolves correctly") {
                            var some = container.bindFromMirror(reflect(instance), toInstance: instance, withDependency: nil)
                            expect(some).notTo(beNil())
                            expect(some).to(beIdenticalTo(instance))
                            expect(some.name).to(equal("Some"))

                            expect(some.service1).notTo(beNil())
                            expect(some.service1).to(beIdenticalTo(service))
                            expect(some.service1?.name).to(equal("Service"))

                            expect(some.service1?.some).notTo(beNil())
                            expect(some.service1?.some).to(beIdenticalTo(some))
                            expect(some.service1?.some?.name).to(equal("Some"))
                        }
                    }

                    context("when the instance is not a subclass of NSObject") {
                        var instance: SomeClass!
                        var service: SomeService!

                        beforeEach {
                            instance = SomeClass()
                            service = SomeService()
                            service.name = "Service"

                            container.clear()
                            container.bind(instance)
                            container.bind(service)
                        }

                        it("auto resolves correctly") {
                            var some = container.bindFromMirror(reflect(instance), toInstance: instance, withDependency: nil)
                            expect(some).notTo(beNil())
                            expect(some).to(beIdenticalTo(instance))

                            expect(some.service).to(beNil())
                        }
                    }
                }
            }
        }
    }
}
