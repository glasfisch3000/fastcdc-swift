import Foundation

public struct FastCDCIterator: IteratorProtocol {
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
    
    public func next() -> Element? {
        guard self.index < self.data.count else { return nil }
        
        let subdata = self.data[self.index...]
        
        switch fastCDCSplit(subdata, minSize: self.minSize, avgSize: self.avgSize, maxSize: self.maxSize) {
        case .tooSmall: return subdata
        case .split(let breakpoint): return subdata[..<breakpoint]
        case .notFound(let length): return subdata[..<length]
        }
    }
}

extension Data {
    public func fastCDC(min: Int, avg: Int, max: Int) -> FastCDCIterator {
        FastCDCIterator(data: self, minSize: min, avgSize: avg, maxSize: max)
    }
}
