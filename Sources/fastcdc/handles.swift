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
        guard self.index < self.data.count else { return nil }
        
        let subdata = self.data[self.index...]
        
        switch fastCDCSplit(subdata, minSize: self.minSize, avgSize: self.avgSize, maxSize: self.maxSize) {
        case .tooSmall:
            self.index += subdata.count
            return subdata
        case .split(let breakpoint):
            self.index += breakpoint
            return subdata[..<breakpoint]
        case .notFound(let length):
            self.index += length
            return subdata[..<length]
        }
    }
}

extension Data {
    public func fastCDC(min: Int, avg: Int, max: Int) -> FastCDCSequence {
        FastCDCSequence(data: self, minSize: min, avgSize: avg, maxSize: max)
    }
}
