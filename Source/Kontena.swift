import Foundation

// MARK: - Custom operators

prefix operator --> {}
prefix func --><T: AnyObject>(inout object: T?)
{
    object = Container.sharedInstance.resolveType(T)
}

postfix operator <-- {}
postfix func <--<T: AnyObject>(inout object: T?)
{
    object = Container.sharedInstance.resolveType(T)
}
