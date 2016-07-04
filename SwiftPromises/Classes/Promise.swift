import UIKit

public enum PromiseState {
    case pending, resolved, rejected
}

public class Promise<T> {
    
    public typealias ResolveCallback = (T) -> Void
    public typealias RejectCallback = (NSError) -> Void
    
    private var onFulfiled: ResolveCallback?
    private var onRejected: RejectCallback?
    
    private var state = PromiseState.pending
    private var result: T?
    private var error: NSError?
    
    public init(body: (resolve: ResolveCallback, reject: RejectCallback) -> Void) {
        //TODO: support exception throw inside body
        
        body(resolve: { self.resolve($0) }, reject: { self.reject($0) })
    }
    
    public func then(onFulfiled onFulfiled: ResolveCallback? = nil, onRejected: RejectCallback? = nil) {
        self.onFulfiled = onFulfiled
        self.onRejected = onRejected
        
        if let result = result where state == .resolved {
            self.onFulfiled?(result)
        }
        if let error = error where state == .rejected {
            self.onRejected?(error)
        }
    }
    
    public func `catch`(onRejected: RejectCallback) {
        self.onRejected = onRejected
    }
    
    private func resolve(result: T) {
        state = .resolved
        self.result = result
        self.onFulfiled?(result)
    }
    
    private func reject(error: NSError) {
        state = .rejected
        self.error = error
        self.onRejected?(error)
    }
}
