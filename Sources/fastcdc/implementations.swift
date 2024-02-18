import Foundation

extension UInt8: FastCDCElement {
    public var byteCount: Int { 1 }
    
    public func fastCDCHash(_ hash: inout UInt, mask: UInt) {
        hash <<= 1
        (hash, _) = hash.addingReportingOverflow(table[Int(self)])
    }
}

extension Data: FastCDCSource {
    public struct OffsetSequence: AsyncSequence, AsyncIteratorProtocol {
        public typealias Element = Data.Element
        
        public var data: Data
        public var offset: Int
        public var index: Int = 0
        
        init(data: Data, offset: Int) {
            self.data = data
            self.offset = offset
        }
        
        public func makeAsyncIterator() -> Self {
            self
        }
        
        public mutating func next() -> Element? {
            guard offset+index < data.count else { return nil }
            
            defer { index += 1 }
            return data[offset+index]
        }
    }
    
    public func makeSubsequence(from offset: Int) -> OffsetSequence {
        OffsetSequence(data: self, offset: offset)
    }
}

extension Data: FastCDCElement {
    public var byteCount: Int { self.count }
    
    public func fastCDCHash(_ hash: inout UInt, mask: UInt) {
        for byte in self {
            hash <<= 1
            (hash, _) = hash.addingReportingOverflow(table[Int(byte)])
            
            if hash & mask == 0 { break }
        }
    }
}

extension Array: FastCDCSource where Element: FastCDCElement {
    public func makeSubsequence(from offset: Int) -> Self.SubSequence {
        self[offset...]
    }
}

extension IndexingIterator: AsyncIteratorProtocol {
    
}

extension ArraySlice: AsyncSequence {
    public func makeAsyncIterator() -> Iterator {
        self.makeIterator()
    }
}
