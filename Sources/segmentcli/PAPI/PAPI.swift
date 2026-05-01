//
//  File.swift
//
//
//  Created by Brandon Sneed on 12/3/21.
//

import Foundation
import SwiftCLI

var PAPIEndpoint: String {
    if useStagingKey.value {
        return "https://api.segmentapis.build/"
    } else {
        // Segment Public API is single-region. EU workspaces use the same host;
        // the token is workspace-scoped server-side. (eu1.segmentapis.com is for
        // event ingestion only, not the Public API.)
        return "https://api.segmentapis.com/"
    }
}

protocol PAPISection {
    static var pathEntry: String { get }
}

// URLSession by default strips Authorization headers on redirect. Segment's
// Public API can issue redirects (e.g. canonicalising trailing slashes) which
// causes a 401 "Authorization header is required" on the followed request.
// This delegate re-attaches the original Authorization header on redirect.
final class PAPIRedirectDelegate: NSObject, URLSessionTaskDelegate {
    static let shared = PAPIRedirectDelegate()
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        var newRequest = request
        if let auth = task.originalRequest?.value(forHTTPHeaderField: "Authorization"),
           newRequest.value(forHTTPHeaderField: "Authorization") == nil {
            newRequest.setValue(auth, forHTTPHeaderField: "Authorization")
        }
        if let accept = task.originalRequest?.value(forHTTPHeaderField: "Accept"),
           newRequest.value(forHTTPHeaderField: "Accept") == nil {
            newRequest.setValue(accept, forHTTPHeaderField: "Accept")
        }
        completionHandler(newRequest)
    }
}

class PAPI {
    enum StatusCode: Int {
        case unknown = 0
        case ok = 200
        case created = 201
        case unauthorized = 401
        case unauthorized2 = 403 // auth returns 403 instead of 401, why?
        case notFound = 404
        case conflict = 409
        case payloadTooLarge = 413
        case unprocessibleEntity = 422
        case tooManyRequests = 429
        case serverError = 500
    }

    static let shared = PAPI()

    let session: URLSession = URLSession(configuration: .default,
                                         delegate: PAPIRedirectDelegate.shared,
                                         delegateQueue: nil)

    let sources = PAPI.Sources()
    let edgeFunctions = PAPI.EdgeFunctions()

    func statusCode(response: URLResponse?) -> StatusCode {
        if let httpResponse = response as? HTTPURLResponse {
            if let status = StatusCode(rawValue: httpResponse.statusCode) {
                return status
            }
        }
        return .unknown
    }

    func authenticate(token: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: PAPIEndpoint) else { completion(nil, nil, "Unable to create URL."); return }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.segment.v1+json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request) { data, response, error in
            if ProcessInfo.processInfo.environment["SEGMENTCLI_DEBUG"] != nil {
                if let httpResponse = response as? HTTPURLResponse {
                    FileHandle.standardError.write("[debug] \(httpResponse.url?.absoluteString ?? request.url?.absoluteString ?? "") -> \(httpResponse.statusCode)\n".data(using: .utf8) ?? Data())
                }
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    FileHandle.standardError.write("[debug] body: \(body)\n".data(using: .utf8) ?? Data())
                }
            }
            completion(data, response, error)
        }
        task.resume()
    }

}

// MARK: - Global option to support staging
let useStagingKey = Flag("--staging", description: "Use Segment staging for operations")
extension Command {
    var isStaging: Bool {
        return useStagingKey.value
    }
}
