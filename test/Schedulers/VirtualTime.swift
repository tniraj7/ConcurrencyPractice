import Foundation
import Combine

struct VirtualTime: Strideable, Comparable {
    var time: Int
    
    init(_ time: Int) {
        self.time = time
    }
    
    static func < (lhs: VirtualTime, rhs: VirtualTime) -> Bool {
        return lhs.time < rhs.time
    }
    
    func distance(to other: VirtualTime) -> Stride {
        return Stride(other.time - time)
    }
    
    func advanced(by n: Stride) -> VirtualTime {
        return VirtualTime(time + n.magnitude)
    }
    
    typealias Stride = VirtualTimeStride
}

