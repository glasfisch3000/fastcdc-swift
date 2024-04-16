public enum CDCBreakpointType {
    case tooSmall // dataset too small to split
    case split // normal, algorithm found a split in the dataset
    case notFound // no split found in the remaining data
    case tooLarge // algorithm hit the set max length before finding a split
}
