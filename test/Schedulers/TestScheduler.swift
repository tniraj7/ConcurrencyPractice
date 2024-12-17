import Foundation
import Combine

class TestScheduler: Scheduler {
    typealias SchedulerTimeType = VirtualTime
    typealias SchedulerOptions = Never
    
    var now: VirtualTime
    let minimumTolerance: SchedulerTimeType.Stride = .init(0)
    private var scheduledActions: [(time: VirtualTime, action: () -> Void)]
    
    init(now: VirtualTime = .init(0)) {
        self.now = now
        self.scheduledActions = []
    }
    
    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        scheduledActions.append((now, action))
    }
    
    func schedule(after date: VirtualTime,
                  tolerance: VirtualTime.Stride,
                  options: SchedulerOptions?,
                  _ action: @escaping () -> Void) {
        scheduledActions.append((date, action))
    }
    
    func schedule(after date: VirtualTime,
                  interval: VirtualTime.Stride,
                  tolerance: VirtualTime.Stride,
                  options: SchedulerOptions?,
                  _ action: @escaping () -> Void) -> Cancellable {
        let cancellable = AnyCancellable {}
        scheduledActions.append((date, action))
        return cancellable
    }
    
    func advance(by stride: VirtualTimeStride = .init(1)) {
        let newTime = now.advanced(by: stride)
        let actions = scheduledActions
            .filter { $0.time <= newTime }
            .sorted { $0.time < $1.time }
        
        scheduledActions = scheduledActions
            .filter { $0.time > newTime }
        
        actions.forEach { $0.action() }
        now = newTime
    }
}
