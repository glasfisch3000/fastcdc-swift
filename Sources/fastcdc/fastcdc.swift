import Foundation

public enum SplitResult {
    case tooSmall
    case split(_ breakpoint: Int)
    case notFound(_ searchLength: Int)
}

public func fastCDCSplit<Source: CDCSource>(_ source: Source, minSize: Int, avgSize: Int, maxSize: Int, offset: Int = 0) -> SplitResult {
    let length = (source.count-offset).bounds(...maxSize)
    guard length > minSize else { return .tooSmall }
    
    let log = UInt(avgSize.bitWidth - avgSize.leadingZeroBitCount)
    let maskS: UInt = (1 << (log-2)) - 1
    let maskL: UInt = (1 << (log+2)) - 1
    
    var hash: UInt = 0
    var i = offset+minSize
    
    for byte in source.makeSubsequence(from: offset+minSize, length: length) {
        i += 1
        
        hash <<= 1
        hash += table[Int(byte)]
        
        if hash & (i-1 < avgSize ? maskS : maskL) == 0 { return .split(offset+i) }
    }
    
    return .notFound(offset+i)
}

public enum SequentialSplitResult<Source: CDCSource> {
    case tooSmall
    case found(_ processed: [Source])
    case notFound(_ processed: [Source])
}

public func fastCDCSplit<Source: CDCSource>(_ sources: [Source], minSize: Int, avgSize: Int, maxSize: Int) -> SequentialSplitResult<Source> {
    let log = UInt(avgSize.bitWidth - avgSize.leadingZeroBitCount)
    let maskS: UInt = (1 << (log-2)) - 1
    let maskL: UInt = (1 << (log+2)) - 1
    
    var hash: UInt = 0
    
    var processed: [Source] = []
    var count = 0
    
    for source in sources {
        guard count >= minSize else { continue }
        guard count + source.count <= maxSize else { break }
        
        for byte in source.makeSubsequence(from: 0, length: source.count) {
            hash <<= 1
            hash += table[Int(byte)]
            
            if hash & (count < avgSize ? maskS : maskL) == 0 { return .found(processed) }
            
            count += 1
        }
        
        processed.append(source)
    }
    
    return .notFound(processed)
}
