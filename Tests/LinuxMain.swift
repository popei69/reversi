import XCTest

import ReversiTests

var tests = [XCTestCaseEntry]()
tests += ReversiServiceTests.allTests()
tests += VariationTests.allTests()
XCTMain(tests)
