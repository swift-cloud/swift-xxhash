# swift-xxhash

A Swift implementation of the [xxHash](https://xxhash.com) hashing algorithm.

## Installation

### Swift Package Manager

To use `swift-xxhash` in your project, add it as a dependency in your
`Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/swift-cloud/swift-xxhash", from: "1.0.0")
]
```

## Usage

```swift
import XXHash

let hash = XXH32().hash("Hello, world!")
print(hash) // 834093149
```

## License

`swift-xxhash` is released under the MIT license.
