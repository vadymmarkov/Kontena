import Foundation
import Quick
import Nimble

class KontenaSpec: QuickSpec
{
    override func spec()
    {
        describe("custom operators") {
            var instance = SomeClass()
            var resolvedInstance: SomeClass?

            beforeEach {
                resolvedInstance = nil
                Container.sharedInstance.clear()
                Container.sharedInstance.bind(instance)
            }

            describe("prefix operator -->") {
                it("resolves correctly") {
                    -->resolvedInstance
                    expect(resolvedInstance).notTo(beNil())
                    expect(instance).to(beIdenticalTo(resolvedInstance))
                }
            }

            describe("postfix operator <--") {
                it("resolves correctly") {
                    resolvedInstance<--
                    expect(resolvedInstance).notTo(beNil())
                    expect(instance).to(beIdenticalTo(resolvedInstance))
                }
            }
        }
    }
}
