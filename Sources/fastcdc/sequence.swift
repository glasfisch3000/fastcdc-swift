import Foundation

extension FastCDCSource {
    public func fastCDC(min: Int, avg: Int, max: Int) -> FastCDCView<Self> {
        FastCDCView(source: self, minBytes: min, avgBytes: avg, maxBytes: max)
    }
}

public struct FastCDCView<Source> where Source: FastCDCSource {
    public var source: Source
    public var minBytes: Int
    public var avgBytes: Int
    public var maxBytes: Int
}

extension FastCDCView {
    public struct Breakpoints: AsyncSequence, AsyncIteratorProtocol {
        public typealias Element = Range<Source.Index>
        
        public var view: FastCDCView
        public var index: Source.Index
        
        public func makeAsyncIterator() -> Self {
            self
        }
        
        public mutating func next() async throws -> Element? {
            await view.source.load(to: index)
            guard index < view.source.endIndex else { return nil }
            
            switch try await view.source[index...].fastCDCNextBreakpoint(minBytes: view.minBytes, avgBytes: view.avgBytes, maxBytes: view.maxBytes) {
            case .tooSmall:
                defer { index = view.source.endIndex }
                return index ..< view.source.endIndex
                
            case .split(let breakpoint):
                defer { index = breakpoint }
                return index ..< breakpoint
                
            case .notFound(let breakpoint, _):
                defer { self.index = breakpoint }
                return index ..< breakpoint
            }
        }
    }
    
    public var breakpoints: Breakpoints { Breakpoints(view: self, index: source.startIndex) }
}

extension FastCDCView where Source.Index == Int {
    public struct Lists: AsyncSequence, AsyncIteratorProtocol {
        public typealias Element = [Source.Element]
        
        public var view: FastCDCView
        public var index: Source.Index
        
        public func makeAsyncIterator() -> Self {
            self
        }
        
        public mutating func next() async throws -> Element? {
            await view.source.load(to: index)
            guard index < view.source.endIndex else { return nil }
            
            let subset = try await view.source[index...].fastCDCNextList(minBytes: view.minBytes, avgBytes: view.avgBytes, maxBytes: view.maxBytes)
            index += subset.count
            return subset
        }
    }
    
    public var sequences: Lists { Lists(view: self, index: source.startIndex) }
}

extension FastCDCView where Source.Index == Int, Source.OffsetSequence.SubSequence == Source.SubSequence {
    public struct Slices: AsyncSequence, AsyncIteratorProtocol {
        public typealias Element = Source.SubSequence
        
        public var view: FastCDCView
        public var index: Source.Index
        
        public func makeAsyncIterator() -> Self {
            self
        }
        
        public mutating func next() async throws -> Element? {
            await view.source.load(to: index)
            guard index < view.source.endIndex else { return nil }
            
            let subset = try await view.source[index...].fastCDCNextSlice(minBytes: view.minBytes, avgBytes: view.avgBytes, maxBytes: view.maxBytes)
            index += subset.count
            return subset
        }
    }
    
    public var slices: Slices { Slices(view: self, index: source.startIndex) }
}
