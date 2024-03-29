import Foundation

public enum FastCDCBreakpointResult<Source: FastCDCSource> {
    case tooSmall
    case split(_ breakpoint: Source.Index)
    case notFound(_ searchLength: Source.Index, lastHash: UInt)
}

extension FastCDCSource {
    public func fastCDCNextBreakpoint(minBytes: Int, avgBytes: Int, maxBytes: Int, seed: UInt = 0) -> FastCDCBreakpointResult<Self> {
        let log = UInt(avgBytes.bitWidth - avgBytes.leadingZeroBitCount)
        let maskS: UInt = (1 << (log-2)) - 1
        let maskL: UInt = (1 << (log+2)) - 1
        
        var hash: UInt = seed
        
        var index = startIndex
        var bytes = 0
        
        for element in self {
            guard bytes + element.byteCount <= maxBytes else { break }
            
            defer { index = self.index(after: index) }
            defer { bytes += element.byteCount }
            
            guard bytes >= minBytes else { continue }
            
            let mask = bytes < avgBytes ? maskS : maskL
            
            element.fastCDCHash(&hash, mask: mask)
            if hash & mask == 0 { return .split(self.index(after: index)) }
        }
        
        return bytes >= minBytes ? .notFound(index, lastHash: hash) : .tooSmall
    }
    
    public func fastCDCNextList(minBytes: Int, avgBytes: Int, maxBytes: Int, seed: UInt = 0) -> [Element] {
        let log = UInt(avgBytes.bitWidth - avgBytes.leadingZeroBitCount)
        let maskS: UInt = (1 << (log-2)) - 1
        let maskL: UInt = (1 << (log+2)) - 1
        
        var hash: UInt = seed
        
        var index = 0
        var bytes = 0
        
        var elements: [Element] = []
        
        for element in self {
            guard bytes + element.byteCount <= maxBytes else { break }
            
            defer { index += 1 }
            defer { bytes += element.byteCount }
            
            guard bytes >= minBytes else { continue }
            
            let mask = bytes < avgBytes ? maskS : maskL
            
            element.fastCDCHash(&hash, mask: mask)
            elements.append(element)
            
            if hash & mask == 0 { return elements }
        }
        
        return elements
    }
}

extension FastCDCSource where Index == Int {
    public func fastCDCNextSlice(minBytes: Int, avgBytes: Int, maxBytes: Int, seed: UInt = 0) -> SubSequence {
        let log = UInt(avgBytes.bitWidth - avgBytes.leadingZeroBitCount)
        let maskS: UInt = (1 << (log-2)) - 1
        let maskL: UInt = (1 << (log+2)) - 1
        
        var hash: UInt = seed
        
        var index = 0
        var bytes = 0
        
        for element in self {
            guard bytes + element.byteCount <= maxBytes else { break }
            
            defer { index += 1 }
            defer { bytes += element.byteCount }
            
            guard bytes >= minBytes else { continue }
            
            let mask = bytes < avgBytes ? maskS : maskL
            
            element.fastCDCHash(&hash, mask: mask)
            if hash & mask == 0 { break }
        }
        
        return self[self.startIndex ..< self.startIndex + index]
    }
}
