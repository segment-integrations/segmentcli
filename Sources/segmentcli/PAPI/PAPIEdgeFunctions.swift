//
//  File.swift
//  
//
//  Created by Brandon Sneed on 7/7/22.
//

import Foundation

extension PAPI {
    class EdgeFunctions: PAPISection {
        static let pathEntry = "edge-functions"
        
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
        
        func disable(token: String, sourceId: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            guard var url = URL(string: PAPIEndpoint) else { completion(nil, nil, "Unable to create URL."); return }
            
            url.appendPathComponent(PAPI.Sources.pathEntry)
            url.appendPathComponent(sourceId)
            url.appendPathComponent(PAPI.EdgeFunctions.pathEntry)
            url.appendPathComponent("disable")
            
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.httpMethod = "PATCH"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{ \"sourceId\": \"\(sourceId)\" }".data(using: .utf8)

            let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
            task.resume()
        }
        
        func generateUploadURL(token: String, sourceId: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            guard var url = URL(string: PAPIEndpoint) else { completion(nil, nil, "Unable to create URL."); return }
            
            url.appendPathComponent(PAPI.Sources.pathEntry)
            url.appendPathComponent(sourceId)
            url.appendPathComponent(PAPI.EdgeFunctions.pathEntry)
            url.appendPathComponent("upload-url")
            
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.httpMethod = "POST"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{ \"sourceId\": \"\(sourceId)\" }".data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
            task.resume()
        }
        
    // http://blah.com/whatever/create?sourceId=1
        
        func createNewVersion(token: String, sourceId: String, uploadURL: URL?, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            guard var url = URL(string: PAPIEndpoint) else { completion(nil, nil, "Unable to create URL."); return }
            guard let uploadURL = uploadURL else { completion(nil, nil, "Upload URL is invalid."); return }
            
            url.appendPathComponent(PAPI.Sources.pathEntry)
            url.appendPathComponent(sourceId)
            url.appendPathComponent(PAPI.EdgeFunctions.pathEntry)
            
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.httpMethod = "POST"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{ \"uploadURL\": \"\(uploadURL.absoluteString)\", \"sourceId\": \"\(sourceId)\" }".data(using: .utf8)

            let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
            task.resume()
        }
        
        func uploadToGeneratedURL(token: String, url: URL?, fileURL: URL?, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            guard let url = url else { completion(nil, nil, "URL is nil."); return }
            guard let fileURL = fileURL else { completion(nil, nil, "File URL is nil."); return }
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.httpMethod = "PUT"
            let task = URLSession.shared.uploadTask(with: request, fromFile: fileURL, completionHandler: completion)
            task.resume()
        }
    }
}
