import Foundation

extension UInt8: FastCDCElement {
    public var byteCount: Int { 1 }
    
    public func fastCDCHash(_ hash: inout UInt, mask: UInt) {
        hash <<= 1
        hash += table[Int(self)]
    }
}

extension Data: FastCDCSource {
    public func makeSubsequence(from offset: Int) -> ArraySlice<UInt8> {
        print("Data.makeSubsequence(from: \(offset))")
        return self.map { $0 }[offset...]
    }
}

extension Data: FastCDCElement {
    public var byteCount: Int { self.count }
    
    public func fastCDCHash(_ hash: inout UInt, mask: UInt) {
        for byte in self {
            hash <<= 1
            hash += table[Int(byte)]
            
            if hash & mask == 0 { break }
        }
    }
}

extension Array: FastCDCSource where Element: FastCDCElement {
    public func makeSubsequence(from offset: Int) -> Self.SubSequence {
        self[offset...]
    }
}
