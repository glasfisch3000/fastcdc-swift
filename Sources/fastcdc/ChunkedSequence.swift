public protocol ChunkedSequence: Sequence where Element == (Subsequence, CDCBreakpointType) {
    associatedtype Subsequence: Sequence
    typealias NestedElement = Subsequence.Element
}

public protocol AsyncChunkedSequence: AsyncSequence where Element == (Subsequence, CDCBreakpointType) {
    associatedtype Subsequence: AsyncSequence
    typealias NestedElement = Subsequence.Element
}
