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
    let children: [Routable] = [EdgeFnLatestCommand(), EdgeFnUpload(), EdgeFnDisable()]
    init() {}
}

class EdgeFnDisable: Command {
    let name = "disable"
    let shortDescription = "Disable Live Plugins for a given source ID"
    
    @Param var sourceId: String

    func execute() throws {
        guard let workspace = currentWorkspace else { exitWithError(code: .commandFailed, message: "No authentication tokens found."); return }
        executeAndWait { semaphore in
            let spinner = Spinner(.dots, "Uploading live plugin ...")
            spinner.start()
            
            PAPI.shared.edgeFunctions.disable(token: workspace.token, sourceId: sourceId) { data, response, error in
                spinner.stop()
                
                if let error = error {
                    exitWithError(error)
                }
                
                let statusCode = PAPI.shared.statusCode(response: response)
                
                switch statusCode {
                case .ok:
                    // success!
                    print("Live plugins disabled for \(self.sourceId.italic.bold).")
                    
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
        
        // generate upload URL
        executeAndWait { semaphore in
            let spinner = Spinner(.dots, "Generating upload URL ...")
            spinner.start()
            
            PAPI.shared.edgeFunctions.generateUploadURL(token: workspace.token, sourceId: sourceId) { data, response, error in
                spinner.stop()
                
                if let error = error {
                    exitWithError(error)
                }
                
                let statusCode = PAPI.shared.statusCode(response: response)
                
                switch statusCode {
                case .ok:
                    // success!
                    if let jsonData = data, let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                        if let uploadString = json[keyPath: "data.uploadURL"] as? String {
                            uploadURL = URL(string: uploadString)
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

        // upload it to the URL we were given.
        executeAndWait { semaphore in
            let spinner = Spinner(.dots, "Uploading \(fileURL.lastPathComponent) ...")
            spinner.start()
            
            PAPI.shared.edgeFunctions.uploadToGeneratedURL(token: workspace.token, url: uploadURL, fileURL: fileURL) { data, response, error in
                spinner.stop()
                
                if let error = error {
                    exitWithError(error)
                }
                
                let statusCode = PAPI.shared.statusCode(response: response)
                
                switch statusCode {
                case .ok:
                    // success!
                    break
                    
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

        // call create to make a new connection to the version we just posted.
        executeAndWait { semaphore in
            let spinner = Spinner(.dots, "Creating new live plugin version ...")
            spinner.start()
            
            PAPI.shared.edgeFunctions.createNewVersion(token: workspace.token, sourceId: sourceId, uploadURL: uploadURL) { data, response, error in
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

