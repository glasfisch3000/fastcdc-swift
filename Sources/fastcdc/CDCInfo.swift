public struct CDCInfo {
    public var minBytes: Int
    public var avgBytes: Int
    public var maxBytes: Int
    
    public init(min: Int, avg: Int, max: Int) {
        self.minBytes = min
        self.avgBytes = avg
        self.maxBytes = max
    }
}
