import Foundation

public enum SplitResult {
    case tooSmall
    case split(_ breakpoint: Int)
    case notFound(_ searchLength: Int)
}

public func fastCDCSplit(_ data: Data, minSize: Int, avgSize: Int, maxSize: Int) -> SplitResult {
    let length = data.count.bounds(...maxSize)
    guard length > minSize else { return .tooSmall }
    
    let log = avgSize.bitWidth - avgSize.leadingZeroBitCount
    let maskS = mask(log+1)
    let maskL = mask(log-1)
    
    let center = centerSize(min: minSize, avg: avgSize, max: length)
    
    var hash: UInt = 0
    var i = minSize
    
    for byte in data[minSize...] {
        hash >>= 1
        hash += UInt(byte)
        
        if hash & (i>center ? maskL : maskS) == 0 { return .split(i) }
        
        i += 1
    }
    
    return .notFound(length)
}
