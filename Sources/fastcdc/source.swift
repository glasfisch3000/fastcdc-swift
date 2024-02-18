import Foundation

public protocol FastCDCSource: AsyncSequence where Element: FastCDCElement {
    associatedtype Index: Comparable
    associatedtype OffsetSequence: FastCDCSource where OffsetSequence.Element == Element, OffsetSequence.Index == Index
    associatedtype SubSequence: FastCDCSource where SubSequence.Element == Element, SubSequence.Index == Index
    
    var count: Int { get }
    
    subscript(indices: PartialRangeFrom<Index>) -> OffsetSequence { get }
    subscript(indices: Range<Index>) -> SubSequence { get }
    
    var startIndex: Index { get }
    var endIndex: Index { get }
    func index(after index: Index) -> Index
    
    func load(to index: Index) async
}

public protocol FastCDCElement {
    var byteCount: Int { get }
    
    func fastCDCHash(_ hash: inout UInt, mask: UInt)
}


extension FastCDCSource {
    public func load(to index: Index) { }
}
