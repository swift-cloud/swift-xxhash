public struct XXH64: Sendable {
    public let seed: UInt64

    public init(seed: UInt64) {
        self.seed = seed
    }
}

extension XXH64 {
    public func hash(_ text: String) -> UInt64 {
        let bytes = Array(text.utf8)
        return hash(bytes)
    }

    public func hash(_ array: [UInt8]) -> UInt64 {
        let len = array.count
        var h: UInt64
        var index = 0

        if len >= 32 {
            let limit = len - 32
            var v1: UInt64 = seed &+ Constants.prime1 &+ Constants.prime2
            var v2: UInt64 = seed &+ Constants.prime2
            var v3: UInt64 = seed
            var v4: UInt64 = seed &- Constants.prime1

            while index <= limit {
                let currentBytes1 = array[index..<index + 8]
                let currentBytes2 = array[index + 8..<index + 16]
                let currentBytes3 = array[index + 16..<index + 24]
                let currentBytes4 = array[index + 24..<index + 32]

                v1 = round64(
                    v1, input: currentBytes1.withUnsafeBytes { $0.load(as: UInt64.self).littleEndian })
                v2 = round64(
                    v2, input: currentBytes2.withUnsafeBytes { $0.load(as: UInt64.self).littleEndian })
                v3 = round64(
                    v3, input: currentBytes3.withUnsafeBytes { $0.load(as: UInt64.self).littleEndian })
                v4 = round64(
                    v4, input: currentBytes4.withUnsafeBytes { $0.load(as: UInt64.self).littleEndian })

                index += 32
            }

            h =
                rotateLeft64(v1, r: 1) &+ rotateLeft64(v2, r: 7) &+ rotateLeft64(v3, r: 12)
                &+ rotateLeft64(v4, r: 18)
            h = mergeRound64(h, val: v1)
            h = mergeRound64(h, val: v2)
            h = mergeRound64(h, val: v3)
            h = mergeRound64(h, val: v4)
        } else {
            h = seed &+ Constants.prime5
        }

        h &+= UInt64(len)

        return finalize64(h, array: array, len: len, index: index)
    }
}

extension XXH64 {
    private enum Constants {
        static let prime1: UInt64 = 11_400_714_785_074_694_791
        static let prime2: UInt64 = 14_029_467_366_897_019_727
        static let prime3: UInt64 = 1_609_587_929_392_839_161
        static let prime4: UInt64 = 9_650_029_242_287_828_579
        static let prime5: UInt64 = 2_870_177_450_012_600_261
    }
}

extension XXH64 {
    private func round64(_ acc: UInt64, input: UInt64) -> UInt64 {
        var acc = acc
        acc &+= input &* Constants.prime2
        acc = rotateLeft64(acc, r: 31)
        acc &*= Constants.prime1
        return acc
    }

    private func rotateLeft64(_ value: UInt64, r: UInt64) -> UInt64 {
        return (value << r) | (value >> (64 - r))
    }

    private func finalize64(_ h: UInt64, array: [UInt8], len: Int, index: Int) -> UInt64 {
        var h = h
        var index = index

        while index + 8 <= len {
            let currentBytes = array[index..<index + 8]
            let k1 = currentBytes.withUnsafeBytes { pointer in
                pointer.load(as: UInt64.self).littleEndian
            }
            h ^= round64(0, input: k1)
            h = rotateLeft64(h, r: 27) &* Constants.prime1 &+ Constants.prime4
            index += 8
        }

        if index + 4 <= len {
            let currentBytes = array[index..<index + 4]
            let k1 = currentBytes.withUnsafeBytes { pointer in
                UInt64(pointer.load(as: UInt32.self).littleEndian)
            }
            h ^= k1 &* Constants.prime1
            h = rotateLeft64(h, r: 23) &* Constants.prime2 &+ Constants.prime3
            index += 4
        }

        while index < len {
            h ^= UInt64(array[index]) &* Constants.prime5
            h = rotateLeft64(h, r: 11) &* Constants.prime1
            index += 1
        }

        h ^= h >> 33
        h &*= Constants.prime2
        h ^= h >> 29
        h &*= Constants.prime3
        h ^= h >> 32

        return h
    }

    private func mergeRound64(_ acc: UInt64, val: UInt64) -> UInt64 {
        let val = round64(0, input: val)
        var acc = acc
        acc ^= val
        acc = acc &* Constants.prime1 &+ Constants.prime4
        return acc
    }
}
