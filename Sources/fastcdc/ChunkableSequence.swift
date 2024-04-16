public protocol ChunkableSequence: Sequence {
    associatedtype Chunked: ChunkedSequence where Chunked.NestedElement == Element
    func chunk(info: CDCInfo) -> Chunked
}

public protocol AsyncChunkableSequence: AsyncSequence {
    associatedtype Chunked: AsyncChunkedSequence where Chunked.NestedElement == Element
    func chunk(info: CDCInfo) -> Chunked
}
