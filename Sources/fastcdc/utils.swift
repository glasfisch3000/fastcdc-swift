extension Int {
    func bounds(_ bounds: ClosedRange<Self>) -> Self {
        Swift.min(bounds.upperBound, Swift.max(bounds.lowerBound, self))
    }
    
    func bounds(_ bounds: Range<Self>) -> Self {
        Swift.min(bounds.upperBound-1, Swift.max(bounds.lowerBound, self))
    }
    
    func bounds(_ bounds: PartialRangeFrom<Self>) -> Self {
        Swift.max(bounds.lowerBound, self)
    }
    
    func bounds(_ bounds: PartialRangeThrough<Self>) -> Self {
        Swift.min(bounds.upperBound, self)
    }
    
    func bounds(_ bounds: PartialRangeUpTo<Self>) -> Self {
        Swift.min(bounds.upperBound-1, self)
    }
}
