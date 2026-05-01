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
        return "https://api.segmentapis.com/"
    }
}

protocol PAPISection {
    static var pathEntry: String { get }
}

// URLSession strips Authorization on redirect by default; api.segmentapis.com
// 30x's to regional hosts (e.g. eu1.api.segmentapis.com) for EU workspaces.
final class PAPIRedirectDelegate: NSObject, URLSessionTaskDelegate {
    static let shared = PAPIRedirectDelegate()
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        var newRequest = request
        for header in ["Authorization", "Accept"] {
            if let value = task.originalRequest?.value(forHTTPHeaderField: header),
               newRequest.value(forHTTPHeaderField: header) == nil {
                newRequest.setValue(value, forHTTPHeaderField: header)
            }
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

    let session = URLSession(configuration: .default,
                             delegate: PAPIRedirectDelegate.shared,
                             delegateQueue: nil)

    let sources = PAPI.Sources()
    let edgeFunctions = PAPI.EdgeFunctions()

    func statusCode(response: URLResponse?) -> StatusCode {
        if let httpResponse = response as? HTTPURLResponse,
           let status = StatusCode(rawValue: httpResponse.statusCode) {
            return status
        }
        return .unknown
    }

    func authenticate(token: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: PAPIEndpoint) else { completion(nil, nil, "Unable to create URL."); return }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.segment.v1+json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request, completionHandler: completion)
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
