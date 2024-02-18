import Foundation

extension FastCDCSource {
    public func fastCDC(min: Int, avg: Int, max: Int) -> FastCDCSequence<Self> {
        FastCDCSequence(source: self, minBytes: min, avgBytes: avg, maxBytes: max)
    }
}

public struct FastCDCSequence<Source>: AsyncSequence where Source: FastCDCSource {
    public typealias Element = Range<Int>
    
    public var source: Source
    
    public var minBytes: Int
    public var avgBytes: Int
    public var maxBytes: Int
    
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(source: source, minBytes: minBytes, avgBytes: avgBytes, maxBytes: maxBytes)
    }
}

extension FastCDCSequence {
    public struct AsyncIterator: AsyncIteratorProtocol {
        public var source: Source
        public var index: Int = 0
        
        public var minBytes: Int
        public var avgBytes: Int
        public var maxBytes: Int
        
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
}

extension FastCDCSequence {
    public struct Lists: AsyncSequence, AsyncIteratorProtocol {
        public typealias Element = [Source.Element]
        
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
            
            let subset = try await source.fastCDCNextSubsequence(minBytes: minBytes, avgBytes: avgBytes, maxBytes: maxBytes, offset: index)
            index += subset.count
            return subset
        }
    }
    
    public var sequences: Lists { Lists(source: source, minBytes: minBytes, avgBytes: avgBytes, maxBytes: maxBytes) }
}

extension FastCDCSequence where Source: Collection, Source.Index == Int {
    public var slices: AsyncMapSequence<Self, Source.SubSequence> {
        self.map { self.source[$0] }
    }
}
