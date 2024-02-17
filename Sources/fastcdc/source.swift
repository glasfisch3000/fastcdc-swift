import Foundation

public protocol FastCDCSource {
    associatedtype OffsetSequence: Sequence where OffsetSequence.Element == Element
    associatedtype Element: FastCDCElement
    
    var count: Int { get }
    
    func makeSubsequence(from offset: Int) -> OffsetSequence
}

public protocol FastCDCElement {
    var byteCount: Int { get }
    
    func fastCDCHash(_ hash: inout UInt, mask: UInt)
}
