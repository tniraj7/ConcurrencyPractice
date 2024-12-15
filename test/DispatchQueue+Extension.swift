import Foundation

protocol Dispatching {
    func executeOnMainThread(
        group: DispatchGroup?,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping () -> Void
    )
}

extension DispatchQueue: Dispatching {
    func executeOnMainThread(
        group: DispatchGroup?,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping () -> Void
    ) {
        if Thread.isMainThread {
            async(group: group, qos: qos, flags: flags, execute: work)
        } else {
            DispatchQueue.main.async(group: group, qos: qos, flags: flags, execute: work)
        }
    }
}

final class MockDispatchQueue: Dispatching {
    func executeOnMainThread(
        group: DispatchGroup?,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping () -> Void
    ) {
        work()
    }
}
