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
        print("iterator called (index: \(index), data: \(data.count))")
        guard index < data.count else { return nil }
        
        print("calling fastCDC")
        switch fastCDCSplit(data, minSize: minSize, avgSize: avgSize, maxSize: maxSize, offset: index) {
        case .tooSmall:
            print("chunk too small")
            defer { index = data.count }
            return data[index...]
        case .split(let breakpoint):
            print("chunk split at \(breakpoint)")
            defer { index += breakpoint }
            return data[index..<breakpoint]
        case .notFound(let length):
            print("no match found; chunk split at \(length)")
            defer { self.index += length }
            return data[index..<length]
        }
    }
}

extension Data {
    public func fastCDC(min: Int, avg: Int, max: Int) -> FastCDCSequence {
        FastCDCSequence(data: self, minSize: min, avgSize: avg, maxSize: max)
    }
}
