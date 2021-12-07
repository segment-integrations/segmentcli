//
//  File.swift
//  
//
//  Created by Brandon Sneed on 12/7/21.
//

import Foundation
import SwiftCLI
import mustache

class ScaffoldCommand: Command {
    let name = "scaffold"
    let shortDescription = "Create baseline implementation of a given code artifact"

    @Flag("-p", "--plugin", description: "Generate an analytics plugin (objc/swift/java/kotlin/ts)")
    var plugin: Bool
    
    @Flag("-e", "--edgefn", description: "Generate an edge function (js)")
    var edgeFn: Bool

    @Flag("-i", "--importer", description: "Generate a CSV importer script (js)")
    var importer: Bool
    
    @Flag("--objc", description: "Use Objective-C for generated plugin")
    var useObjc: Bool
    @Flag("--swift", description: "Use Swift for generated plugin")
    var useSwift: Bool
    @Flag("--java", description: "Use Java for generated plugin")
    var useJava: Bool
    @Flag("--kotlin", description: "Use Kotlin for generated plugin")
    var useKotlin: Bool
    @Flag("--ts", description: "Use Typescript for generated plugin")
    var useTypescript: Bool
    @Flag("--js", description: "Use Javascript for generated edgefn/importer")
    var useJavascript: Bool

    @Key("-n", "--name", description: "Optionally specify a name for the generated scaffold")
    var nameParam: String?
    
    var scaffoldName: String?
    let fileManager = FileManager.default
    
    var optionGroups: [OptionGroup] {
        return [
            .atLeastOne($plugin, $edgeFn, $importer),
            .atMostOne($plugin, $edgeFn, $importer),
            .atLeastOne($useObjc, $useSwift, $useJava, $useKotlin, $useTypescript, $useJavascript)]
    }
    
    func execute() throws {
        if nameParam == nil {
            if plugin {
                scaffoldName = "MyPlugin"
            } else if edgeFn {
                scaffoldName = "MyEdgeFunction"
            } else if importer {
                scaffoldName = "MyCSVImporter"
            }
        } else {
            scaffoldName = nameParam
        }
        
        if plugin && useSwift {
            generateSwiftPlugin()
        }
    }
    
    func generateSwiftPlugin() {
        guard let scaffoldName = scaffoldName else {
            exitWithError("Could not determine a plugin name to use.")
            return
        }
        
        let filename = scaffoldName + ".swift"
        
        print("Generating a Swift Plugin from template...")
 
        for file in plugin_templates_swift {
            if fileManager.fileExists(atPath: filename) {
                let overwrite = Input.readBool(prompt: "\(filename) exists.  Overwrite? [y/N]: ", defaultValue: false)
                if overwrite == false {
                    exitWithError(code: .commandFailed)
                }
            }
            let generate = Mustache(file)
            let result = generate(name: scaffoldName, filename: filename)
            do {
                try result.write(toFile: filename, atomically: true, encoding: .utf8)
                print("Created \(filename).")
            } catch {
                exitWithError("Unable to write \(filename)")
            }
        }
        
        print("\n")
    }
}
