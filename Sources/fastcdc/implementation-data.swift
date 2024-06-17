import Foundation

extension Data: ChunkableSequence {
    public struct Chunked: ChunkedSequence, IteratorProtocol {
        public typealias Subsequence = Data
        
        public var source: Data
        public var info: CDCInfo
        
        public var index: Int
        public var endIndex: Int
        public var seed: UInt
        
        public func makeIterator() -> Self { self }
    }
    
    public func chunk(info: CDCInfo) -> Chunked {
        Chunked(source: self, info: info, index: self.startIndex, endIndex: self.endIndex, seed: 0)
    }
}

extension Data.Chunked {
    public mutating func next() -> (Data, CDCBreakpointType)? {
        guard index < endIndex else { return nil }
        
        let log = UInt(self.info.avgBytes.bitWidth - self.info.avgBytes.leadingZeroBitCount)
        let maskS: UInt = (1 << (log+2)) - 1
        let maskL: UInt = (1 << (log-2)) - 1
        
        var byteCount = 0
        var hash = self.seed
        
        let status = source.withUnsafeBytes { bytes -> CDCBreakpointType in
            for index in self.index ..< endIndex {
                byteCount += 1
                guard byteCount < info.maxBytes else { return .tooLarge }
                
                let mask = byteCount < info.avgBytes ? maskS : maskL
                hash <<= 1
                (hash, _) = hash.addingReportingOverflow(table[Int(bytes[index])])
                
                guard byteCount >= info.minBytes else { continue }
                
                if hash & mask == 0 { return .split }
            }
            
            return byteCount >= info.minBytes ? .notFound : .tooSmall
        }
        
        let subdata = self.source[self.index ..< self.index+byteCount]
        
        self.index += byteCount
        self.seed = hash
        
        return (subdata, status)
    }
}
