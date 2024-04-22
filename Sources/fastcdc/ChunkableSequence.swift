public protocol ChunkableSequence {
    associatedtype Element
    associatedtype Chunked: ChunkedSequence where Chunked.NestedElement == Element
    
    func chunk(info: CDCInfo) -> Chunked
}

public protocol AsyncChunkableSequence {
    associatedtype Element
    associatedtype Chunked: AsyncChunkedSequence where Chunked.NestedElement == Element
    
    func chunk(info: CDCInfo) -> Chunked
}
