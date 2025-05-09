//
//  File.swift
//  
//
//  Created by Brandon Sneed on 12/8/21.
//

import Foundation
import SwiftCLI

class REPLCommand: Command {
    let name: String = "repl"
    let shortDescription = "Segment virtual development environment"
    
    @Key("-r", "--runscript", "Runs the supplied script in the REPL")
    var scriptFile: String?
    
    func execute() throws {
        if let scriptFile = scriptFile {
            runJSFile(path: scriptFile)
        } else {
            runJSInteractive()
        }
    }
    
}
