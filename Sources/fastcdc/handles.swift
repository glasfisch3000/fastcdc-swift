import Foundation

public struct FastCDCSequence: Sequence, IteratorProtocol {
    public typealias Element = Data
    
    public var data: Data
    public var index: Int = 0
    
    public var minSize: Int
    public var avgSize: Int
    public var maxSize: Int
    
    init(data: Data, minSize: Int, avgSize: Int, maxSize: Int) {
        self.data = data
        self.minSize = minSize
        self.avgSize = avgSize
        self.maxSize = maxSize
    }
    
    public mutating func next() -> Element? {
        guard index < data.count else { return nil }
        
        switch fastCDCSplit(data, minSize: minSize, avgSize: avgSize, maxSize: maxSize, offset: index) {
        case .tooSmall:
            defer { index = data.count }
            return data[index...]
        case .split(let breakpoint):
            defer { index = breakpoint }
            return data[index..<breakpoint]
        case .notFound(let breakpoint):
            defer { self.index = breakpoint }
            return data[index..<breakpoint]
        }
    }
}

extension Data {
    public func fastCDC(min: Int, avg: Int, max: Int) -> FastCDCSequence {
        FastCDCSequence(data: self, minSize: min, avgSize: avg, maxSize: max)
    }
}
