import Testing
import XXHash

@Test func testHash32() {
    let hash = XXH32(seed: 0).hash("Hello, world!")
    #expect(hash == 834_093_149)
}

@Test func testHash64() {
    let hash = XXH64(seed: 0).hash("Hello, world!")
    #expect(hash == 17_691_043_854_468_224_118)
}
