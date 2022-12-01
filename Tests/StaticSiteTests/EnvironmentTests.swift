    import XCTest
    @testable import StaticSite

    let url = URL(string: "file:///tmp")!


    final class StaticSiteTests: XCTestCase {
        func testRun() throws {
            struct TestOutputPath: Rule {
                var exp: XCTestExpectation
                var body: some Rule {
                    let _ = exp.fulfill()
                    EmptyRule()
                }
            }

            let exp = XCTestExpectation()
            try TestOutputPath(exp: exp)
                .builtin
                .run(environment: .init(inputBaseURL: url, outputBaseURL: url))
            wait(for: [exp], timeout: 0)
        }

        func testOutputPath() throws {
            struct TestOutputPath: Rule {
                var exp: XCTestExpectation
                var body: some Rule {
                    EnvironmentReader { env in
                        let _ = XCTAssertEqual(env.output, URL(string: "file:///tmp/")!)
                        let _ = exp.fulfill()
                        EmptyRule()
                    }
                }
            }

            let exp = XCTestExpectation()
            try TestOutputPath(exp: exp)
                .builtin
                .run(environment: .init(inputBaseURL: url, outputBaseURL: url))
            wait(for: [exp], timeout: 0)
        }

        func testOutputPath2() throws {
            struct TestOutputPath: Rule {
                var exp: XCTestExpectation
                var body: some Rule {
                    EnvironmentReader { env in
                        let _ = XCTAssertEqual(env.output, URL(string: "file:///tmp/sub")!)
                        let _ = exp.fulfill()
                        EmptyRule()
                    }
                }
            }

            let exp = XCTestExpectation()
            try TestOutputPath(exp: exp)
                .outputPath("sub")
                .builtin
                .run(environment: .init(inputBaseURL: url, outputBaseURL: url))
            wait(for: [exp], timeout: 0)
        }

        func testRelativeOutputPath() throws {
            struct TestOutputPath: Rule {
                var exp: XCTestExpectation
                var body: some Rule {
                    EnvironmentReader { env in
                        let _ = XCTAssertEqual(env.relativeOutputPath, "/sub")
                        let _ = exp.fulfill()
                        EmptyRule()
                    }
                }
            }

            let exp = XCTestExpectation()
            try TestOutputPath(exp: exp)
                .outputPath("sub")
                .builtin
                .run(environment: .init(inputBaseURL: url, outputBaseURL: url))
            wait(for: [exp], timeout: 0)
        }
    }
