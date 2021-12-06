//
//  File.swift
//  
//
//  Created by Brandon Sneed on 12/6/21.
//

import Foundation
import SwiftCLI

class ImportCommand: Command {
    let name = "import"
    let shortDescription = "Import CSV data into Segment from"
    
    @Param var csvFile: String
    @Param var configFile: String
    @Param var writeKey: String
    
    /*
    @Key("-csv", "--csv", description: "CSV file to read from")
    var csvFile: String?
    
    @Key("-csvConfig", "--csvConfig", description: "A config file describing how to interpret CSV columns to event data")
    var configFile: String?
     */
    func execute() throws {
    }
}
