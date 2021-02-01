import NIO

/// A utility for running expensive CPU work on threads so as not to
/// block the current `EventLoop`.
public struct Thread {
    static var pool: NIOThreadPool {
        Container.main.resolve(NIOThreadPool.self)
    }
    
    /// Runs an expensive bit of work on a thread that isn't backing
    /// an `EventLoop`, returning any value generated by that work
    /// back on the current `EventLoop`.
    ///
    /// - Parameter task: The work to run.
    /// - Returns: A future containing the result of the expensive
    ///   work that completes on the current `EventLoop`.
    public static func run<T>(_ task: @escaping () throws -> T) -> EventLoopFuture<T> {
        return Thread.pool.runIfActive(eventLoop: Loop.current, task)
    }
}
