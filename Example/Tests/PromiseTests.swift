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
        promise.then(onFulfiled: { result in
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
        promise.then(onFulfiled: { result in
            XCTAssertEqual(result, testResult)
            wasCalled = true
        })
        XCTAssertTrue(wasCalled)
    }
    
    func testAsyncReject() {
        let expectation = expectationWithDescription("")
        let promise = Promise<Int>() { (resolve, reject) in
            dispatchAfter(0.1) {
                reject(NSError(domain: "123", code: 123, userInfo: nil))
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
                reject(NSError(domain: "123", code: 123, userInfo: nil))
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
            throw NSError(domain: "123", code: 123, userInfo: nil)
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
                reject(NSError(domain: "123", code: 123, userInfo: nil))
            }
        }
        
        var onFulfiledCalled = false
        var onRejectedCalled = false
        promise.then(onFulfiled: { result in
                onFulfiledCalled = true
            }, onRejected: { error in
                onRejectedCalled = true
        })
        
        let expectation = expectationWithDescription("")
        dispatchAfter(0.3) { 
            expectation.fulfill()
            XCTAssertTrue(onFulfiledCalled, "onFulfiled should be called")
            XCTAssertFalse(onRejectedCalled, "onRejected should not be called")
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
}

func dispatchAfter(delayInSeconds: Float, block: () -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Float(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
}
