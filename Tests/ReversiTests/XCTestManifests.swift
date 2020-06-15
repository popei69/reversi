import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ReversiServiceTests.allTests),
        testCase(VariationTests.allTests),
    ]
}
#endif
