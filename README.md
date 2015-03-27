# Kontena (コンテナ)

[![CI Status](http://img.shields.io/travis/markvaldy/Kontena.svg?style=flat)](https://travis-ci.org/markvaldy/Kontena)
[![Version](https://img.shields.io/cocoapods/v/Kontena.svg?style=flat)](http://cocoadocs.org/docsets/Kontena)
[![License](https://img.shields.io/cocoapods/l/Kontena.svg?style=flat)](http://cocoadocs.org/docsets/Kontena)
[![Platform](https://img.shields.io/cocoapods/p/Kontena.svg?style=flat)](http://cocoadocs.org/docsets/Kontena)

## IOC container in Swift

A simple Swift implementation of Service Locator / IOC container with limited DI functionality. Works well with Swift and Objective C classes.

## Additional notes

- If you want to bind Swift protocol you must add ```@objc``` annotation.
- Your bound object must inherit from NSObject to let the container automatically resolve dependencies.  
- Swift 1.2 is required to use this library.

## Usage

### Create the container

```swift
import Kontena

let container = Container() // init
let sharedContainer = Container.sharedInstance // as singleton
```

### Merge two containers

```swift
// all bound objects from container2
// are merged and added to container1
container1.mergeWithContainer(container2)
```

### Clear the container

```swift
container.clear()
```

### Let the container automatically resolve dependencies of bound objects

```swift
container.resolveDependencies = true
```

### Bind/register the instance/factory

```swift
@objc protocol SomeProtocol {}
class SomeBaseClass: NSObject {}
class SomeClass: SomeBaseClass, SomeProtocol {}

var instance = SomeClass()

// as singleton to the type of the instance
container.bind(instance)
// as singleton to the superclass type
container.bind(instance, toType: SomeBaseClass.self)
// as singleton to the protocol
container.bind(instance, toType: SomeProtocol.self)
// as singleton to the key
container.bind(instance, toKey: "some")

// factory = closure where the object is initialized
let factory = {
  () -> SomeClass in
  let some = SomeClass()
  // basic initialization
  return some
}

// to the type of the instance
container.bindFactory(factory)
// to the type of the instance
container.bindFactory(factory, toType: SomeBaseClass.self)
// to the protocol
container.bindFactory(factory, toType: SomeProtocol.self)
// to the key
container.bindFactory(factory, toKey: "some")

// you can bind factory as singleton as well
container.bindFactory(factory).asSingleton()
```

### Resolve the object

```swift
// return resolved object or nil
var resolvedByType = container.resolveType(SomeClass.self)
var resolvedByKey = container.resolveKey(key)
```

### Using of custom operators
```swift
var instance = SomeClass()
var resolvedInstance: SomeClass?

// should be bound to the shared container
Container.sharedInstance.bind(instance)

// Resolve and inject from the container
-->resolvedInstance // prefix operator
resolvedInstance<-- // postfix operator

```

## Installation

**Kontena** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Kontena'
```

## Author

Vadym Markov, impressionwave@gmail.com

## License

**Kontena** is available under the MIT license. See the LICENSE file for more info.
