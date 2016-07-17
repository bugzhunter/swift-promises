import UIKit

public enum PromiseState {
    case pending, resolved, rejected
}

public class Promise<T> {
    
    public typealias ResolveCallback = (T) -> Void
    public typealias RejectCallback = (ErrorType) -> Void
    
    private var onFulfiled: ResolveCallback?
    private var onRejected: RejectCallback?
    
    private var state = PromiseState.pending
    private var result: T?
    private var error: ErrorType?
    
    public init(body: (resolve: ResolveCallback, reject: RejectCallback) throws -> Void) {
        do {
            try body(resolve: { self.resolve($0) }, reject: { self.reject($0) })
        }
        catch {
            self.error = error
            self.reject(error)
        }
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
    
    public func error(onRejected: RejectCallback) {
        self.onRejected = onRejected
        if let error = error where state == .rejected {
            self.onRejected?(error)
        }
    }
    
    private func resolve(result: T) {
        guard state == .pending else { return }
        
        state = .resolved
        self.result = result
        self.onFulfiled?(result)
    }
    
    private func reject(error: ErrorType) {
        guard state == .pending else { return }
        
        state = .rejected
        self.error = error
        self.onRejected?(error)
    }
}
