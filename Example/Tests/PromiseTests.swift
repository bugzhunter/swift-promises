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
        let expectation = expectationWithDescription("testDispatchAfter")
        dispatchAfter(0.1) {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testSimpleThen() {
        let testResult: Int = 1
        let expectation = expectationWithDescription("testDispatchAfter")
        let promise = Promise<Int>() {resolve, reject in
            dispatchAfter(0.1) {
                resolve(testResult)
            }
        }
        promise.then(onFulfiled: {result in
            expectation.fulfill()
            XCTAssertEqual(result, testResult)
        })
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testSyncPromise() {
        let testResult: Int = 1
        let promise = Promise<Int>() { resolve, reject in
            resolve(testResult)
        }
        var wasCalled = false
        promise.then(onFulfiled: {result in
            XCTAssertEqual(result, testResult)
            wasCalled = true
        })
        XCTAssertTrue(wasCalled)
    }
    
}

func dispatchAfter(delayInSeconds: Float, block: () -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Float(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
}
