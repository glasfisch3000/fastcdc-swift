import Foundation

public struct FastCDCSequence<Source: FastCDCSource>: AsyncSequence, AsyncIteratorProtocol {
    public typealias Element = Range<Int>
    
    public var source: Source
    public var index: Int = 0
    
    public var minBytes: Int
    public var avgBytes: Int
    public var maxBytes: Int
    
    public func makeAsyncIterator() -> Self {
        self
    }
    
    public mutating func next() async throws -> Element? {
        guard index < source.count else { return nil }
        
        switch try await source.fastCDCSplit(minBytes: minBytes, avgBytes: avgBytes, maxBytes: maxBytes, offset: index) {
        case .tooSmall:
            defer { index = source.count }
            return index ..< source.count
            
        case .split(let breakpoint):
            defer { index = breakpoint }
            return index ..< breakpoint
            
        case .notFound(let breakpoint, _):
            defer { self.index = breakpoint }
            return index ..< breakpoint
        }
    }
}

extension FastCDCSource {
    public func fastCDCSequence(minBytes: Int, avgBytes: Int, maxBytes: Int) -> FastCDCSequence<Self> {
        FastCDCSequence(source: self, minBytes: minBytes, avgBytes: avgBytes, maxBytes: maxBytes)
    }
}
