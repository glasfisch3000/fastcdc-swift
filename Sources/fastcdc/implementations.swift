import Foundation

extension UInt8: FastCDCElement {
    public var byteCount: Int { 1 }
    
    public func fastCDCHash(_ hash: inout UInt, mask: UInt) {
        hash <<= 1
        (hash, _) = hash.addingReportingOverflow(table[Int(self)])
    }
}

extension Data: FastCDCSource {
    public typealias OffsetSequence = SubSequence
    public typealias AsyncIterator = Iterator
    
    public func makeAsyncIterator() -> Iterator {
        self.makeIterator()
    }
}

extension Data.Iterator: AsyncIteratorProtocol { }

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

extension Array: FastCDCSource, AsyncSequence where Element: FastCDCElement {
    public typealias OffsetSequence = SubSequence
    
    public func makeAsyncIterator() -> Iterator {
        self.makeIterator()
    }
}

extension ArraySlice: FastCDCSource, AsyncSequence where Element: FastCDCElement {
    public typealias OffsetSequence = SubSequence
    
    public func makeAsyncIterator() -> Iterator {
        self.makeIterator()
    }
}

extension IndexingIterator: AsyncIteratorProtocol where Elements: FastCDCSource { }

extension Array: FastCDCElement where Element == UInt8 {
    public var byteCount: Int { self.count }
    
    public func fastCDCHash(_ hash: inout UInt, mask: UInt) {
        for byte in self {
            hash <<= 1
            (hash, _) = hash.addingReportingOverflow(table[Int(byte)])
            
            if hash & mask == 0 { break }
        }
    }
}

extension ArraySlice: FastCDCElement where Element == UInt8 {
    public var byteCount: Int { self.count }
    
    public func fastCDCHash(_ hash: inout UInt, mask: UInt) {
        for byte in self {
            hash <<= 1
            (hash, _) = hash.addingReportingOverflow(table[Int(byte)])
            
            if hash & mask == 0 { break }
        }
    }
}
