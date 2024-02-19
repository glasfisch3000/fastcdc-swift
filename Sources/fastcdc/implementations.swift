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
    public typealias OffsetSequence = SubSequence
}

extension ArraySlice: FastCDCSource where Element: FastCDCElement {
    public typealias OffsetSequence = SubSequence
}

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
