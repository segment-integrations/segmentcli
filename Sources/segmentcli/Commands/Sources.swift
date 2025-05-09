//
//  File.swift
//  
//
//  Created by Brandon Sneed on 7/7/22.
//

import Foundation
import SwiftCLI
import Spinner
import ColorizeSwift
import Segment

class SourcesGroup: CommandGroup {
    let name = "sources"
    let shortDescription = "View and edit workspace sources"
    let children: [Routable] = [SourcesListCommand()]
    init() {}
}

class SourcesListCommand: Command {
    let name = "list"
    let shortDescription = "Get info about sources on this workspace"
    
    func execute() throws {
        guard let workspace = currentWorkspace else { exitWithError(code: .commandFailed, message: "No authentication tokens found."); return }

        executeAndWait { semaphore in
            let spinner = Spinner(.dots, "Retrieving sources info ...")
            spinner.start()
            
            PAPI.shared.sources.list(token: workspace.token) { data, response, error in
                spinner.stop()
                
                if let error = error {
                    exitWithError(error)
                }
                
                let statusCode = PAPI.shared.statusCode(response: response)
                
                switch statusCode {
                case .ok:
                    // success!
                    if let jsonData = data, let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                        let sources = json[keyPath: "data.sources"] as? [[String: Any]]
                        
                        if let sources = sources {
                            for source in sources {
                                let name: String = source["name"] as! String
                                let sourceId: String = source["id"] as! String
                                let sourceType: String? = source[keyPath: "metadata.name"] as? String
                                let writeKeys: [String]? = source["writeKeys"] as? [String]
                                
                                print("Source: \(name.white)")
                                print("    id: \(sourceId.italic.bold)")
                                if let sourceType = sourceType {
                                    print("    type: \(sourceType.italic.bold)")
                                }
                                if let writeKeys = writeKeys {
                                    if writeKeys.count > 0 {
                                        print("    writekeys:")
                                        writeKeys.forEach { writekey in
                                            print("        \(writekey.italic.bold)")
                                        }
                                    }
                                }
                                print("")
                            }
                            //for (profile, workspace) in profiles {
                            //    print("    Profile: \(profile.italic().bold()), Workspace: \(workspace.slug.italic().bold())")
                            //}

                        }
                    }
                    
                case .unauthorized:
                    fallthrough
                case .unauthorized2:
                    exitWithError(code: .commandFailed, message: "Supplied token is not authorized.")
                default:
                    exitWithError("An unknown error occurred.")
                }
                semaphore.signal()
            }
        }
    }
}
