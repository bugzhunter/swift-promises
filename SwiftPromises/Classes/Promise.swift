import UIKit

public enum PromiseState {
    case pending, resolved, rejected
}

public class Promise<T> {
    
    public typealias ResolveCallback = (T) -> Void
//    public typealias ResolveCallback2 = <R>(T) -> R
    public typealias RejectCallback = (ErrorType) -> Void
    
    private var onFulfilledCallbacks: [ResolveCallback] = []
    private var onRejectedCallbacks: [RejectCallback] = []
    
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
    
    public func then(onFulfilled onFulfilled: ResolveCallback? = nil, onRejected: RejectCallback? = nil) {
        addOnFulfilledCallback(onFulfilled)
        addOnRejectedCallback(onRejected)
        
        if let result = result where state == .resolved {
            callOnFulfilled(result)
        }
        if let error = error where state == .rejected {
            callOnRejected(error)
        }
    }
    
    public func error(onRejected: RejectCallback) {
        addOnRejectedCallback(onRejected)
        if let error = error where state == .rejected {
            callOnRejected(error)
        }
    }
    
    private func resolve(result: T) {
        guard state == .pending else { return }
        
        state = .resolved
        self.result = result
        callOnFulfilled(result)
    }
    
    private func reject(error: ErrorType) {
        guard state == .pending else { return }
        
        state = .rejected
        self.error = error
        callOnRejected(error)
    }
    
    private func addOnFulfilledCallback(onFulfilled: ResolveCallback?) {
        if let onFulfilled = onFulfilled {
            onFulfilledCallbacks.append(onFulfilled)
        }
    }
    
    private func addOnRejectedCallback(onRejected: RejectCallback?) {
        if let onRejected = onRejected {
            onRejectedCallbacks.append(onRejected)
        }
    }
    
    private func callOnFulfilled(result: T) {
        for callback in onFulfilledCallbacks {
            callback(result)
        }
    }
    
    private func callOnRejected(error: ErrorType) {
        for callback in onRejectedCallbacks {
            callback(error)
        }
    }
}
