//
//  File.swift
//  
//
//  Created by Brandon Sneed on 12/3/21.
//

import Foundation
import SwiftCLI
import Segment

// MARK: - Helper methods

func executeAndWait(_ closure: (DispatchSemaphore) -> Void) {
    let semaphore = DispatchSemaphore(value: 0)
    closure(semaphore)
    semaphore.wait()
}


// MARK: - Exits & Errors

enum ErrorCode: Int {
    case success = 0
    case unknown = 1
    case commandFailed = 2
    case networkError = 3
    case filesystemError = 4
}

func exitWithError(code: ErrorCode) {
    exit(Int32(code.rawValue))
}

func exitWithError(code: ErrorCode, message: String) {
    fputs("Error: \(message)\n\n", stderr)
    exit(Int32(code.rawValue))
}

func exitWithError(_ error: Error) {
    if let str = error as? String {
        fputs("Error: \(str)\n\n", stderr)
    } else {
        fputs("Error: \(error.localizedDescription)\n\n", stderr)
    }
    exit(Int32(ErrorCode.commandFailed.rawValue))
}

// useful for error handling
extension String: Error {}

// MARK: - Segment helper functions

func eventStorageDirectory(writeKey: String) -> URL {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let docURL = urls[0]
    let segmentURL = docURL.appendingPathComponent("segment/\(writeKey)/")
    // try to create it, will fail if already exists, nbd.
    // tvOS, watchOS regularly clear out data.
    try? FileManager.default.createDirectory(at: segmentURL, withIntermediateDirectories: true, attributes: nil)
    return segmentURL
}


