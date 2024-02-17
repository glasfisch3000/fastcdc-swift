import Foundation

struct FastCDCSequence<Source: FastCDCSource>: Sequence, IteratorProtocol {
    typealias Element = Range<Int>
    
    var source: Source
    var index: Int = 0
    
    var minBytes: Int
    var avgBytes: Int
    var maxBytes: Int
    
    mutating func next() -> Element? {
        guard index < source.count else { return nil }
        
        switch source.fastCDCSplit(minBytes: minBytes, avgBytes: avgBytes, maxBytes: maxBytes, offset: index) {
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
    public func fastCDCSequence(minBytes: Int, avgBytes: Int, maxBytes: Int) -> some Sequence<Range<Int>> {
        FastCDCSequence(source: self, minBytes: minBytes, avgBytes: avgBytes, maxBytes: maxBytes)
    }
}
