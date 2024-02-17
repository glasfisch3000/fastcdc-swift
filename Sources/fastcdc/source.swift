import Foundation

public protocol CDCSource {
    associatedtype OffsetSequence: Sequence where OffsetSequence.Element == UInt8
    
    var count: Int { get }
    
    func makeSubsequence(from offset: Int, length: Int) -> OffsetSequence
}

extension Data: CDCSource {
    public struct OffsetSequence: Sequence, IteratorProtocol {
        public typealias Element = Data.Element
        
        public var data: Data
        public var offset: Int
        public var length: Int
        public var index: Int = 0
        
        init(data: Data, offset: Int, length: Int) {
            self.data = data
            self.offset = offset
            self.length = length
        }
        
        public mutating func next() -> Element? {
            guard offset+index < length.bounds(...data.count) else { return nil }
            
            defer { index += 1 }
            return data[offset+index]
        }
    }
    
    public func makeSubsequence(from offset: Int, length: Int) -> OffsetSequence {
        OffsetSequence(data: self, offset: offset, length: length)
    }
}
