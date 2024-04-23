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

extension ChunkableSequence {
    public func chunk(min: Int, avg: Int, max: Int) -> Chunked {
        self.chunk(info: .init(min: min, avg: avg, max: max))
    }
}

extension AsyncChunkableSequence {
    public func chunk(min: Int, avg: Int, max: Int) -> Chunked {
        self.chunk(info: .init(min: min, avg: avg, max: max))
    }
}
