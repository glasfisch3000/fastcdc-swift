import Foundation

public enum FastCDCSplitResult {
    case tooSmall
    case split(_ breakpoint: Int)
    case notFound(_ searchLength: Int, lastHash: UInt)
}

public enum FastCDCSubsequenceResult {
    
}

extension FastCDCSource {
    public func fastCDCSplit(minBytes: Int, avgBytes: Int, maxBytes: Int, offset: Int = 0, seed: UInt = 0) async throws -> FastCDCSplitResult {
        let log = UInt(avgBytes.bitWidth - avgBytes.leadingZeroBitCount)
        let maskS: UInt = (1 << (log-2)) - 1
        let maskL: UInt = (1 << (log+2)) - 1
        
        var hash: UInt = seed
        
        var index = offset
        var bytes = 0
        
        for try await element in self.makeSubsequence(from: offset) {
            defer { index += 1 }
            defer { bytes += element.byteCount }
            
            guard bytes >= minBytes else { continue }
            guard bytes + element.byteCount < maxBytes else { break }
            
            let mask = bytes < avgBytes ? maskS : maskL
            
            element.fastCDCHash(&hash, mask: mask)
            if hash & mask == 0 { return .split(index+1) }
        }
        
        return bytes >= minBytes ? .notFound(index, lastHash: hash) : .tooSmall
    }
    
    public func fastCDCNextSubsequence(minBytes: Int, avgBytes: Int, maxBytes: Int, offset: Int = 0, seed: UInt = 0) async throws -> [Element] {
        let log = UInt(avgBytes.bitWidth - avgBytes.leadingZeroBitCount)
        let maskS: UInt = (1 << (log-2)) - 1
        let maskL: UInt = (1 << (log+2)) - 1
        
        var hash: UInt = seed
        
        var index = offset
        var bytes = 0
        
        var elements: [Element] = []
        
        for try await element in self.makeSubsequence(from: offset) {
            defer { index += 1 }
            defer { bytes += element.byteCount }
            
            guard bytes >= minBytes else { continue }
            guard bytes + element.byteCount < maxBytes else { break }
            
            let mask = bytes < avgBytes ? maskS : maskL
            
            element.fastCDCHash(&hash, mask: mask)
            elements.append(element)
            
            if hash & mask == 0 { return elements }
        }
        
        return elements
    }
}

extension FastCDCSource where Self: Collection, Index == Int {
    public func fastCDCNextSubsequence(minBytes: Int, avgBytes: Int, maxBytes: Int, offset: Int = 0, seed: UInt = 0) async throws -> SubSequence {
        let log = UInt(avgBytes.bitWidth - avgBytes.leadingZeroBitCount)
        let maskS: UInt = (1 << (log-2)) - 1
        let maskL: UInt = (1 << (log+2)) - 1
        
        var hash: UInt = seed
        
        var index = offset
        var bytes = 0
        
        for try await element in self.makeSubsequence(from: offset) {
            defer { index += 1 }
            defer { bytes += element.byteCount }
            
            guard bytes >= minBytes else { continue }
            guard bytes + element.byteCount < maxBytes else { break }
            
            let mask = bytes < avgBytes ? maskS : maskL
            
            element.fastCDCHash(&hash, mask: mask)
            if hash & mask == 0 { return self[offset ... offset + index] }
        }
        
        return self[offset...]
    }
}
