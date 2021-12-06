//
//  Settings.swift
//  
//
//  Created by Brandon Sneed on 12/3/21.
//

import Foundation

class Settings: Codable {
    class Workspace: Codable {
        var token: String
        var id: String
        var slug: String
        
        init(token: String, id: String, slug: String) {
            self.token = token
            self.id = id
            self.slug = slug
        }
    }
    
    var profiles: [String: Workspace]?
    var defaultProfile: String?
    
    init() {
        profiles = nil
        defaultProfile = nil
    }
}

extension Settings {
    static var settingsFile: URL {
        return URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".segmentcli")
    }
    
    static func load() -> Settings {
        var settings: Settings? = nil
        
        let decoder = JSONDecoder()
        if let data = try? Data(contentsOf: settingsFile) {
            settings = try? decoder.decode(Settings.self, from: data)
        }
        
        if let settings = settings {
            return settings
        } else {
            return Settings()
        }
    }

    func save() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self) {
            try? data.write(to: Self.settingsFile)
        }
    }
}
