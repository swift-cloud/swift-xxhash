public struct XXH32: Sendable {
    public let seed: UInt32

    public init(seed: UInt32) {
        self.seed = seed
    }
}

extension XXH32 {
    public func hash(_ text: String) -> UInt32 {
        let bytes = Array(text.utf8)
        return hash(bytes)
    }

    public func hash(_ array: [UInt8]) -> UInt32 {
        let len = array.count
        var h: UInt32
        var index = 0

        if len >= 16 {
            let limit = len - 16
            var v1: UInt32 = seed &+ Constants.prime1 &+ Constants.prime2
            var v2: UInt32 = seed &+ Constants.prime2
            var v3: UInt32 = seed
            var v4: UInt32 = seed &- Constants.prime1

            while index <= limit {
                let currentBytes1 = array[index..<index + 4]
                let currentBytes2 = array[index + 4..<index + 8]
                let currentBytes3 = array[index + 8..<index + 12]
                let currentBytes4 = array[index + 12..<index + 16]

                v1 = round32(
                    v1, input: currentBytes1.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian })
                v2 = round32(
                    v2, input: currentBytes2.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian })
                v3 = round32(
                    v3, input: currentBytes3.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian })
                v4 = round32(
                    v4, input: currentBytes4.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian })

                index += 16
            }

            h =
                rotateLeft32(v1, r: 1) &+ rotateLeft32(v2, r: 7) &+ rotateLeft32(v3, r: 12)
                &+ rotateLeft32(v4, r: 18)
        } else {
            h = seed &+ Constants.prime5
        }

        h &+= UInt32(len)

        return finalize32(h, array: array, len: len, index: index)
    }
}

extension XXH32 {
    private struct Constants {
        static let prime1: UInt32 = 2_654_435_761
        static let prime2: UInt32 = 2_246_822_519
        static let prime3: UInt32 = 3_266_489_917
        static let prime4: UInt32 = 668_265_263
        static let prime5: UInt32 = 374_761_393
    }
}

extension XXH32 {

    private func round32(_ acc: UInt32, input: UInt32) -> UInt32 {
        var acc = acc
        acc &+= input &* Constants.prime2
        acc = rotateLeft32(acc, r: 13)
        acc &*= Constants.prime1
        return acc
    }

    private func rotateLeft32(_ value: UInt32, r: UInt32) -> UInt32 {
        return (value << r) | (value >> (32 - r))
    }

    private func finalize32(_ h: UInt32, array: [UInt8], len: Int, index: Int) -> UInt32 {
        var h = h
        var index = index

        while index + 4 <= len {
            let currentBytes = array[index..<index + 4]
            let k1 = currentBytes.withUnsafeBytes { pointer in
                pointer.load(as: UInt32.self).littleEndian
            }
            h &+= k1 &* Constants.prime3
            h = rotateLeft32(h, r: 17) &* Constants.prime4
            index += 4
        }

        while index < len {
            h &+= UInt32(array[index]) &* Constants.prime5
            h = rotateLeft32(h, r: 11) &* Constants.prime1
            index += 1
        }

        h ^= h >> 15
        h &*= Constants.prime2
        h ^= h >> 13
        h &*= Constants.prime3
        h ^= h >> 16

        return h
    }
}
