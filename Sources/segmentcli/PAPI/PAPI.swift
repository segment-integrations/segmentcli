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
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
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
