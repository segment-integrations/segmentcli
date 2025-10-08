//
//  File.swift
//  
//
//  Created by Brandon Sneed on 7/7/22.
//

import Foundation

extension PAPI {
    class EdgeFunctions: PAPISection {
        static let pathEntry = "live-plugins"
        
        func latest(token: String, sourceId: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            guard var url = URL(string: PAPIEndpoint) else { completion(nil, nil, "Unable to create URL."); return }
            
            url.appendPathComponent(PAPI.Sources.pathEntry)
            url.appendPathComponent(sourceId)
            url.appendPathComponent(PAPI.EdgeFunctions.pathEntry)
            url.appendPathComponent("latest")
            
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
            task.resume()
        }
        
    // http://blah.com/whatever/create?sourceId=1

        func createNewVersion(token: String, sourceId: String, code: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            guard var url = URL(string: PAPIEndpoint) else { completion(nil, nil, "Unable to create URL."); return }
            guard !code.isEmpty else { completion(nil, nil, "Code cannot be empty."); return }
            
            url.appendPathComponent(PAPI.Sources.pathEntry)
            url.appendPathComponent(sourceId)
            url.appendPathComponent(PAPI.EdgeFunctions.pathEntry)
            
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.httpMethod = "POST"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{ \"code\": \"\(code)\", \"sourceId\": \"\(sourceId)\" }".data(using: .utf8)

            let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
            task.resume()
        }
    }
}
