//
//  File.swift
//  
//
//  Created by Brandon Sneed on 12/3/21.
//

import Foundation

let PAPIEndpoint: String = "https://api.segmentapis.com/"

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
