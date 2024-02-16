import Foundation

public enum SplitResult {
    case tooSmall
    case split(_ breakpoint: Int)
    case notFound(_ searchLength: Int)
}

public func fastCDCSplit(_ data: Data, minSize: Int, avgSize: Int, maxSize: Int, offset: Int = 0) -> SplitResult {
    let length = (data.count-offset).bounds(...maxSize)
    guard length > minSize else { return .tooSmall }
    
    let log = UInt(avgSize.bitWidth - avgSize.leadingZeroBitCount)
    let maskS: UInt = (1 << (log-2)) - 1
    let maskL: UInt = (1 << (log+2)) - 1
    
    print("  len: \(data[offset...])")
    print("  min: \(minSize)")
    print("  max: \(length)")
    print("  \(data[offset+minSize ..< offset+length])")
    
    var hash: UInt = 0
    var i = offset+minSize
    
    for byte in data[offset+minSize ..< offset+length] {
        i += 1
        
        hash <<= 1
        hash += table[Int(byte)]
        print("  byte \(i-1) -> \(String(format: "%016x", hash)) (\(String(format: "%016x", i<avgSize ? maskS : maskL)))")
        
        if hash & (i<avgSize ? maskS : maskL) == 0 { return .split(i) }
    }
    
    return .notFound(i)
}
