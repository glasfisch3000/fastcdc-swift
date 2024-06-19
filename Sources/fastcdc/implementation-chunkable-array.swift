import Foundation

extension [Data]: ChunkableSequence {
    public struct Chunked: ChunkedSequence, IteratorProtocol {
        public typealias Element = (ArraySlice<Data>, CDCBreakpointType)
        public typealias Subsequence = ArraySlice<Data>
        
        public var source: [Data]
        public var info: CDCInfo
        
        public var index: Int
        public var endIndex: Int
        public var seed: UInt
        
        public func makeIterator() -> Self { self }
        
        public mutating func next() -> Element? {
            guard index < endIndex else { return nil }
            
            let log = UInt(self.info.avgBytes.bitWidth - self.info.avgBytes.leadingZeroBitCount)
            let maskS: UInt = (1 << (log+2)) - 1
            let maskL: UInt = (1 << (log-2)) - 1
            
            var index = self.index
            var byteCount = 0
            var hash = self.seed
            
            var resultStatus: CDCBreakpointType = .tooSmall
            
            loop: while index < endIndex {
                let data = source[index]
                
                guard byteCount + data.count < info.maxBytes else {
                    resultStatus = .tooLarge
                    break
                }
                defer { index += 1 }
                
                let status = data.withUnsafeBytes { bytes -> CDCBreakpointType in
                    var offset = 0
                    while offset < bytes.endIndex {
                        byteCount += 1
                        defer { offset += 1 }
                        
                        let mask = byteCount < info.avgBytes ? maskS : maskL
                        hash <<= 1
                        (hash, _) = hash.addingReportingOverflow(table[Int(bytes[offset])])
                        
                        guard byteCount >= info.minBytes else { continue }
                        if hash & mask == 0 { return .split }
                    }
                    
                    return byteCount >= info.minBytes ? .notFound : .tooSmall
                }
                
                resultStatus = status
                switch status {
                case .tooSmall: continue
                case .notFound: continue
                case .split: break loop
                case .tooLarge: break loop
                }
            }
            
            let subArray = self.source[self.index ..< index]
            
            self.index = index
            self.seed = hash
            
            return (subArray, resultStatus)
        }
    }
    
    public func chunk(info: CDCInfo) -> Chunked {
        Chunked(source: self, info: info, index: self.startIndex, endIndex: self.endIndex, seed: 0)
    }
}
