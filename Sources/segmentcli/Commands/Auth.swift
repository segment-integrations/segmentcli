//
//  Auth.swift
//  
//
//  Created by Brandon Sneed on 12/2/21.
//

import Foundation
import SwiftCLI
import Spinner
import ColorizeSwift

class AuthCommand: Command {
    let name = "auth"
    let shortDescription = "Authenticate with Segment.com and assign a profile name"
    
    @Param var profileName: String
    @Param var authToken: String
    
    func execute() throws {
        let profileName = self.profileName
        
        executeAndWait { semaphore in
            let spinner = Spinner(.dots, "Authenticating with Segment ...")
            spinner.start()
            
            PAPI.shared.authenticate(token: authToken) { data, response, error in
                spinner.stop()
                
                if let error = error {
                    exitWithError(error)
                }
                
                let statusCode = PAPI.shared.statusCode(response: response)
                
                switch statusCode {
                case .ok:
                    // success!
                    let settings = Settings.load()

                    if let jsonData = data, let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                        let data = json["data"] as? [String: Any]
                        let workspace = data?["workspace"] as? [String: Any]
                        let id = workspace?["id"] as? String
                        let slug = workspace?["slug"] as? String
                        
                        if settings.profiles == nil {
                            settings.profiles = [String: Settings.Workspace]()
                            settings.defaultProfile = profileName
                        }
                        
                        if var profiles = settings.profiles, let id = id, let slug = slug {
                            let existing = profiles[profileName]
                            if existing != nil {
                                exitWithError(code: .commandFailed, message: "A profile named `\(profileName)` exists already.")
                            }
                            
                            profiles[profileName] = Settings.Workspace(token: self.authToken, id: id, slug: slug)
                            settings.profiles = profiles
                            settings.save()
                        }
                    } else {
                        exitWithError(code: .networkError, message: "Invalid workspace data was returned from the server.")
                    }
                    
                    print("\nSuccess!\n")
                    
                case .unauthorized:
                    fallthrough
                case .unauthorized2:
                    exitWithError(code: .commandFailed, message: "Supplied token is not authorized.")
                default:
                    exitWithError("The service failed to authenticate your token.")
                }
                semaphore.signal()
            }
        }
    }
    
}
