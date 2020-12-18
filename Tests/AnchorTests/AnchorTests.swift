//
//  AnchorTests.swift
//
//
//  Created by Ian Sampson on 2020-12-18.
//

import XCTest
@testable import Anchor

final class NISTTests: XCTestCase {
    func testCertificateChains() {
        NIST.tests.forEach {
            let url = Resources.nist
                .appendingPathComponent("test\($0.number)", isDirectory: true)
            do {
                try NIST.validateCertificateChain(at: url)
                switch $0.expectedResult {
                case .valid:
                    return
                case .invalid:
                    XCTFail("Validated invalid chain in Test\($0.number).")
                }
            } catch {
                switch $0.expectedResult {
                case .valid:
                    XCTFail("Test\($0.number) failed with error: \(error.localizedDescription)")
                    return
                case .invalid:
                    // Test succeeded.
                    return
                }
            }
        }
    }

    static var allTests = [
        ("testCertificateChains", testCertificateChains)
    ]
}

// TODO:
// * Make API more flexible, allowing for chains of arbitrary length
// as well as intermediate (but untrusted) certificates.
// * Make the API more Swifty (see CryptoKit).
// * Consider making Certificate static, e.g. a struct.
// * Remove app data and add anonymous tests, including failing certificates.
// * Check for memory leaks.
// * Commit.
// * Rename CCryptoBoringSSL to AnchorBoringSSL or something similar.
// * Check expiry date