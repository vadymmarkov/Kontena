import UIKit
import Kontena

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {

        Container.sharedInstance.resolveDependencies = true

        var some = SomeClass()
        Container.sharedInstance.bind(some, toType: SomeBaseClass.self)

        var serviceFactory = {
            () -> SomeService in
            let service = SomeService()
            return service
        }
        Container.sharedInstance.bindFactory(serviceFactory, toType: NamedService.self)

        return true
    }
}

@objc protocol NamedService
{
    var name: String { get }
}

class SomeService: NamedService
{
    @objc var name = "Service"
}


class SomeBaseClass: NSObject
{
    var name: String {
        get {
            return "Some Base"
        }
    }
    var service: NamedService?
}

class SomeClass: SomeBaseClass
{
    override var name: String {
        get {
            return "Some"
        }
    }
}
