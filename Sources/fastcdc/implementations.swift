import Foundation

extension UInt8: FastCDCElement {
    public var byteCount: Int { 1 }
    
    public func fastCDCHash(_ hash: inout UInt, mask: UInt) {
        hash <<= 1
        hash += table[Int(self)]
    }
}

extension Data: FastCDCSource {
    public struct OffsetSequence: Sequence, IteratorProtocol {
        public typealias Element = Data.Element
        
        public var data: Data
        public var offset: Int
        public var index: Int = 0
        
        init(data: Data, offset: Int) {
            self.data = data
            self.offset = offset
        }
        
        public mutating func next() -> Element? {
            print("\(self).next()", terminator: "")
            defer { print() }
            
            guard offset+index < data.count else { print(" -> end", terminator: ""); return nil }
            
            let value = data[offset+index]
            index += 1
            print(" -> \(value)", terminator: "")
            return value
        }
    }
    
    public func makeSubsequence(from offset: Int) -> OffsetSequence {
        print("Data.makeSubsequence(from: \(offset))")
        return OffsetSequence(data: self, offset: offset)
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
