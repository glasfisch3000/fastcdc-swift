import Foundation

public enum FastCDCSplitResult {
    case tooSmall
    case split(_ breakpoint: Int)
    case notFound(_ searchLength: Int, lastHash: UInt)
}

extension FastCDCSource {
    public func fastCDCSplit(minBytes: Int, avgBytes: Int, maxBytes: Int, offset: Int = 0, seed: UInt = 0) -> FastCDCSplitResult {
        let log = UInt(avgBytes.bitWidth - avgBytes.leadingZeroBitCount)
        let maskS: UInt = (1 << (log-2)) - 1
        let maskL: UInt = (1 << (log+2)) - 1
        
        var hash: UInt = seed
        
        var index = offset
        var bytes = 0
        
        print("fastCDC \(self)")
        
        for element in self.makeSubsequence(from: offset) {
            guard bytes >= minBytes else { continue }
            guard bytes + element.byteCount <= maxBytes else { break }
            
            let mask = bytes < avgBytes ? maskS : maskL
            
            element.fastCDCHash(&hash, mask: mask)
            print("  index \(index) bytes \(bytes) -> \(String(format: "%016x", hash)) & \(String(format: "%016x", mask)) \(hash & mask == 0 ? "==" : "!=") 0")
            if hash & mask == 0 { return .split(index+1) }
            
            index += 1
            bytes += element.byteCount
        }
        
        return bytes >= minBytes ? .notFound(index, lastHash: hash) : .tooSmall
    }
}
