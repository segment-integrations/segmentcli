//
//  File.swift
//  
//
//  Created by Brandon Sneed on 12/6/21.
//

import Foundation
import SwiftCLI
import JavaScriptCore
import mustache

class ImportCommand: Command {
    let name = "import"
    let shortDescription = "Import CSV data into Segment from"
    
    @Param var writeKey: String
    @Param var csvFile: String
    
    let jsContext = JSContext()!
    
    func execute() throws {
        let generate = Mustache(importer_js)
        let result = generate(name: "", writeKey: writeKey, csvFile: csvFile)
        
        runJS(script: result, context: jsContext)
    }
}
