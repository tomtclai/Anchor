//
//  NIST.swift
//  
//
//  Created by Ian Sampson on 2020-12-18.
//

import Foundation
import Anchor

extension NIST {
    static let tests = [
        Test(1, .valid),
        Test(2, .invalid),
        Test(3, .invalid),
        Test(4, .valid),
        Test(5, .invalid),
        Test(6, .invalid),
        Test(7, .valid),
        Test(8, .invalid),
        Test(9, .invalid),
        Test(10, .invalid),
        Test(11, .invalid),
        Test(12, .valid),
    ]
}

struct NIST {
    enum Error: Swift.Error {
        case missingAnchor
    }
    
    struct Test {
        let number: Int
        let expectedResult: Result
        
        init(_ number: Int, _ expectedResult: Result) {
            self.number = number
            self.expectedResult = expectedResult
        }
        
        enum Result {
            case valid
            case invalid
        }
    }
    
    static func validateCertificateChain(at url: URL) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        let _ = try contents
            .filter {
                return $0.pathExtension == "crt"
            }
            .sorted {
                let filenameA = $0.lastPathComponent
                let filenameB = $1.lastPathComponent
                
                func prioritize(_ string: String) -> Bool? {
                    if filenameA.contains(string) && !filenameB.contains(string) {
                        return true
                    } else if filenameB.contains(string) && !filenameA.contains(string) {
                        return false
                    }
                    return nil
                }
                return prioritize("Trust Anchor")
                    ?? prioritize("Intermediate Certificate")
                    ?? (filenameA < filenameB)
            }
            .map {
                (
                    certificate: try Certificate(contentsOf: $0, format: .der),
                    filename: $0.lastPathComponent
                )
            }
            .reduce(nil) { (trust: Trust?, element: (certificate: Certificate, filename: String)) -> Trust in
                let certificate = element.certificate
                let filename = element.filename
                
                if let trust = trust {
                    print("Validating \(filename).")
                    return try trust.validatingAndAppending(certificate: certificate)
                } else {
                    guard filename.contains("Trust Anchor") else {
                        throw Error.missingAnchor
                    }
                    return Trust(anchor: certificate)
                }
            }
    }
}