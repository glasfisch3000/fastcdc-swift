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
    
    print("  \(maskS)")
    print("  \(maskL)")
    
    let center = centerSize(min: minSize, avg: avgSize, max: length)
    
    print("  min: \(minSize)")
    print("  avg: \(avgSize)")
    print("  max: \(maxSize)")
    print("  center: \(center)")
    
    var hash: UInt = 0
    var i = minSize
    
    for byte in data[minSize..<length] {
        i += 1
        
        hash >>= 1
        hash += table[Int(byte)]
        print("  byte \(i-1) -> \(String(format: "%016xl", hash)) (\(String(format: "%016xl", i>center ? maskL : maskS)))")
        
        if hash & (i>center ? maskL : maskS) == 0 { return .split(i) }
    }
    
    return .notFound(length)
}
