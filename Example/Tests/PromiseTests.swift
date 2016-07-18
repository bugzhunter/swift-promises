import XCTest
import SwiftPromises

class PromiseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDispatchAfter() {
        let expectation = expectationWithDescription("")
        dispatchAfter(0.1) {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testAsyncThen() {
        let testResult: Int = 1
        let expectation = expectationWithDescription("")
        let promise = Promise<Int>() { (resolve, reject) in
            dispatchAfter(0.1) {
                resolve(testResult)
            }
        }
        promise.then(onFulfilled: { result in
            expectation.fulfill()
            XCTAssertEqual(result, testResult)
        })
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testSyncThen() {
        let testResult: Int = 1
        let promise = Promise<Int>() { (resolve, reject) in
            resolve(testResult)
        }
        var wasCalled = false
        promise.then(onFulfilled: { result in
            XCTAssertEqual(result, testResult)
            wasCalled = true
        })
        XCTAssertTrue(wasCalled)
    }
    
    func testAsyncReject() {
        let expectation = expectationWithDescription("")
        let promise = Promise<Int>() { (resolve, reject) in
            dispatchAfter(0.1) {
                reject(NSError(domain: "322", code: 322, userInfo: nil))
            }
        }
        promise.then(onRejected: { error in
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testCatchOnAsyncReject() {
        let expectation = expectationWithDescription("")
        let promise = Promise<Int>() { (resolve, reject) in
            dispatchAfter(0.1) {
                reject(NSError(domain: "322", code: 322, userInfo: nil))
            }
        }
        promise.error({ error in
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testCatchOnSyncThrow() {
        let expectation = expectationWithDescription("")
        let promise = Promise<Int>() { (resolve, reject) in
            throw NSError(domain: "322", code: 322, userInfo: nil)
        }
        promise.error({ error in
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testRejectAfterResolve() {
        let testResult: Int = 1
        let promise = Promise<Int>() { (resolve, reject) in
            dispatchAfter(0.1) {
                resolve(testResult)
            }
            dispatchAfter(0.2) {
                reject(NSError(domain: "322", code: 322, userInfo: nil))
            }
        }
        
        var onFulfilledCalled = false
        var onRejectedCalled = false
        promise.then(onFulfilled: { result in
                onFulfilledCalled = true
            }, onRejected: { error in
                onRejectedCalled = true
        })
        
        let expectation = expectationWithDescription("")
        dispatchAfter(0.3) { 
            expectation.fulfill()
            XCTAssertTrue(onFulfilledCalled, "onFulfilled should be called")
            XCTAssertFalse(onRejectedCalled, "onRejected should not be called")
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testMultipleOnFulfiled() {
        let testResult = 1
        let promise = createSuccessPromise(1)
        var counter = 0
        promise.then(onFulfilled: { result in
            XCTAssertEqual(result, testResult)
            counter += 1
        })
        promise.then(onFulfilled: { result in
            XCTAssertEqual(result, testResult)
            counter += 1
        })
        promise.then(onFulfilled: { result in
            XCTAssertEqual(result, testResult)
            counter += 1
        })
        
        let expectation = expectationWithDescription("")
        dispatchAfter(0.3) {
            expectation.fulfill()
            XCTAssertEqual(counter, 3)
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
//    func testChainingWithSuccess() {
//        let phase1Result = 322
//        let phase2Result = "test"
//        let phase3Result = ["test": 322]
//        
//        let expectation = expectationWithDescription("")
//        let promise = createSuccessPromise(phase1Result)
//        promise.then(phase2Result.dynamicType) { result in
//            XCTAssertEqual(result, phase1Result)
//            return phase2Result
//        }
//        .then(phase3Result.dynamicType) { result in
//            XCTAssertEqual(result, phase2Result)
//            return phase3Result
//        }
//        .then(onFulfilled: { result in
//            expectation.fulfill()
//            XCTAssertEqual(result, phase3Result)
//        })
//        waitForExpectationsWithTimeout(1, handler: nil)
//    }
    
}

public func then2<X>(block:() -> X) -> X {
    let res = block()
    return res
}

func dispatchAfter(delayInSeconds: Float, block: () -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Float(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
}

func createSuccessPromise<T>(result: T) -> Promise<T> {
    return Promise<T>() { (resolve, reject) in
        dispatchAfter(0.1) {
            resolve(result)
        }
    }
}
