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

class EdgeFnGroup: CommandGroup {
    let name = "liveplugins"
    let shortDescription = "Work with and develop analytics live plugins"
    let children: [Routable] = [EdgeFnLatestCommand(), EdgeFnUpload(), EdgeFnDeleteCode()]
    init() {}
}

class EdgeFnDeleteCode: Command {
    let name = "delete"
    let shortDescription = "Deletes Live Plugin code for a given source ID"
    
    @Param var sourceId: String

    func execute() throws {
        guard let workspace = currentWorkspace else { exitWithError(code: .commandFailed, message: "No authentication tokens found."); return }
        executeAndWait { semaphore in
            let spinner = Spinner(.dots, "Deleting live plugin code ...")
            spinner.start()
            
            PAPI.shared.edgeFunctions.deleteCode(token: workspace.token, sourceId: sourceId) { data, response, error in
                spinner.stop()
                
                if let error = error {
                    exitWithError(error)
                }
                
                let statusCode = PAPI.shared.statusCode(response: response)
                
                switch statusCode {
                case .ok:
                    // success!
                    print("Live plugin code deleted for \(self.sourceId.italic.bold).")
                    
                case .unauthorized:
                    fallthrough
                case .unauthorized2:
                    exitWithError(code: .commandFailed, message: "Supplied token is not authorized.")
                case .notFound:
                    exitWithError(code: .commandFailed, message: "No live plugins were found.")
                default:
                    exitWithError("An unknown error occurred.")
                }
                semaphore.signal()
            }
        }
    }
}


class EdgeFnUpload: Command {
    let name = "upload"
    let shortDescription = "Upload a Live Plugin"
    
    @Param var sourceId: String
    @Param var filePath: String
    
    func execute() throws {
        guard let workspace = currentWorkspace else { exitWithError(code: .commandFailed, message: "No authentication tokens found."); return }
        
        var uploadURL: URL? = nil
        
        let fileURL = URL(fileURLWithPath: filePath.expandingTildeInPath)
        
        // Read file contents
        guard let fileContents = try? Data(contentsOf: fileURL) else {
            exitWithError(code: .commandFailed, message: "Unable to read file contents from \(filePath)")
            return
        }

        // Convert Data to String
        guard let code = String(data: fileContents, encoding: .utf8) else {
            exitWithError(code: .commandFailed, message: "Unable to convert file contents to string. File may not be valid UTF-8.")
            return
        }

        // call create to make a new connection to the version we just posted.
        executeAndWait { semaphore in
            let spinner = Spinner(.dots, "Creating new live plugin version ...")
            spinner.start()

            PAPI.shared.edgeFunctions.createNewVersion(token: workspace.token, sourceId: sourceId, code: code) { data, response, error in
                spinner.stop()
                
                if let error = error {
                    exitWithError(error)
                }
                
                let statusCode = PAPI.shared.statusCode(response: response)
                
                switch statusCode {
                case .ok:
                    // success!
                    if let jsonData = data, let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                        if let json = try? JSON(jsonObject) {
                            print(json.prettyPrint())
                        }
                    }
                    
                case .unauthorized:
                    fallthrough
                case .unauthorized2:
                    exitWithError(code: .commandFailed, message: "Supplied token is not authorized.")
                case .notFound:
                    exitWithError(code: .commandFailed, message: "No live plugins were found.")
                default:
                    exitWithError("An unknown error occurred.")
                }
                semaphore.signal()
            }
        }
        
    }
}

class EdgeFnLatestCommand: Command {
    let name = "latest"
    let shortDescription = "Get info about the latest Live Plugin in use"
    
    @Param var sourceId: String
    
    func execute() throws {
        guard let workspace = currentWorkspace else { exitWithError(code: .commandFailed, message: "No authentication tokens found."); return }

        executeAndWait { semaphore in
            let spinner = Spinner(.dots, "Retrieving latest Live Plugin info ...")
            spinner.start()
            
            PAPI.shared.edgeFunctions.latest(token: workspace.token, sourceId: sourceId) { data, response, error in
                spinner.stop()
                
                if let error = error {
                    exitWithError(error)
                }
                
                let statusCode = PAPI.shared.statusCode(response: response)
                
                switch statusCode {
                case .ok:
                    // success!
                    if let jsonData = data, let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                        if let json = try? JSON(jsonObject) {
                            print(json.prettyPrint())
                        }
                    }
                    
                case .unauthorized:
                    fallthrough
                case .unauthorized2:
                    exitWithError(code: .commandFailed, message: "Supplied token is not authorized.")
                case .notFound:
                    exitWithError(code: .commandFailed, message: "No live plugins were found.")
                default:
                    exitWithError("An unknown error occurred.")
                }
                semaphore.signal()
            }
        }
    }
}

