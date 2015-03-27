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

func nonOptionalTypeName(type: Any.Type) -> String
{
    let string = toString(type)
    let regex = NSRegularExpression(pattern: "(?<=<).+?(?=>)",
        options: nil, error: nil)!

    let results = regex.matchesInString(string, options: nil, range: NSMakeRange(0, count(string)))
        as! [NSTextCheckingResult]
    let matches = map(results) { (string as NSString).substringWithRange($0.range) }

    if matches.count > 0 {
        return matches[0] as String
    }

    return string
}
