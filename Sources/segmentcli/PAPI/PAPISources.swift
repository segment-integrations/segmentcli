//
//  File.swift
//  
//
//  Created by Brandon Sneed on 7/7/22.
//

import Foundation

extension PAPI {
    class Sources: PAPISection {
        static let pathEntry = "sources"
        
        func list(token: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            guard var url = URL(string: PAPIEndpoint) else { completion(nil, nil, "Unable to create URL."); return }
            
            url.appendPathComponent("sources")
            let newURL = url.appending(query: "pagination.count", value: "200")
            
            var request = URLRequest(url: newURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
            task.resume()
        }
    }
}
