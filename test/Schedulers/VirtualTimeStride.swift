import Foundation
import Combine

struct VirtualTimeStride: SchedulerTimeIntervalConvertible, Comparable, SignedNumeric, Hashable {
    var magnitude: Int
    
    init(integerLiteral value: Int) {
        self.magnitude = value
    }
    
    init?<T>(exactly source: T) where T : BinaryInteger {
        self.magnitude = Int(source)
    }
    
    init(_ value: Int) {
        self.magnitude = value
    }
    
    static func < (lhs: VirtualTimeStride, rhs: VirtualTimeStride) -> Bool {
        return lhs.magnitude < rhs.magnitude
    }
    
    static func * (lhs: VirtualTimeStride, rhs: VirtualTimeStride) -> VirtualTimeStride {
        return VirtualTimeStride(lhs.magnitude * rhs.magnitude)
    }
    
    static func + (lhs: VirtualTimeStride, rhs: VirtualTimeStride) -> VirtualTimeStride {
        return VirtualTimeStride(lhs.magnitude + rhs.magnitude)
    }
    
    static func - (lhs: VirtualTimeStride, rhs: VirtualTimeStride) -> VirtualTimeStride {
        return VirtualTimeStride(lhs.magnitude - rhs.magnitude)
    }
    
    static func -= (lhs: inout VirtualTimeStride, rhs: VirtualTimeStride) {
        lhs.magnitude -= rhs.magnitude
    }
    
    static func += (lhs: inout VirtualTimeStride, rhs: VirtualTimeStride) {
        lhs.magnitude += rhs.magnitude
    }
    
    static func *= (lhs: inout VirtualTimeStride, rhs: VirtualTimeStride) {
        lhs.magnitude *= rhs.magnitude
    }
    
    static prefix func - (x: VirtualTimeStride) -> VirtualTimeStride {
        return VirtualTimeStride(-x.magnitude)
    }
    
    static func seconds(_ s: Int) -> VirtualTimeStride {
        return VirtualTimeStride(s)
    }
    
    static func seconds(_ s: Double) -> VirtualTimeStride {
        return VirtualTimeStride(Int(s))
    }
    
    static func milliseconds(_ ms: Int) -> VirtualTimeStride {
        return VirtualTimeStride(ms)
    }
    
    static func microseconds(_ us: Int) -> VirtualTimeStride {
        return VirtualTimeStride(us)
    }
    
    static func nanoseconds(_ ns: Int) -> VirtualTimeStride {
        return VirtualTimeStride(ns)
    }
}
