//
//  File.swift
//  
//
//  Created by Brandon Sneed on 12/8/21.
//

import Foundation
import SwiftCLI
import Segment
//import SwiftJS
import JavaScriptCore

class REPLCommand: Command {
    let name: String = "repl"
    let shortDescription = "Segment virtual development environment"
    
    @Key("-r", "--runscript", "Runs the supplied script in the REPL")
    var scriptFile: String?
    
    let jsContext = JSContext()!
    
    func execute() throws {
        if let scriptFile = scriptFile {
            runJSFile(path: scriptFile, context: jsContext)
        } else {
            runJSInteractive(context: jsContext)
        }
    }
    
}

/*
class REPLCommand: Command {
    let name: String = "repl"
    let shortDescription = "Segment virtual development environment"
    
    @Key("-r", "--runscript", "Runs the supplied script in the REPL")
    var scriptFile: String?
    
    let fileManager = FileManager.default
    
    func execute() throws {
        configureInterpeterRuntime()
        
        if let scriptFile = scriptFile {
            if fileManager.fileExists(atPath: scriptFile) {
                do {
                    try Lox.runFile(path: scriptFile)
                } catch {
                    exitWithError(error.localizedDescription)
                }
            } else {
                exitWithError("\(scriptFile) does not exist!")
            }
        } else {
            print("Welcome to the Segment Analytics REPL.  Type :help for assistance.")
            Lox.runPrompt()
        }
    }
    
}
 */

/*
guard let writeKey = args[0] as? String else { return NilAny }
self.analytics = Analytics(configuration: Configuration(writeKey: writeKey).flushAt(1))

let analyticsClass = LoxClass(name: "Analytics", superclass: nil, methods: [
    "track": LoxFunction(name: "track", declaration:
                            Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                          parameters: [Token(type: .string, lexeme: "", literal: nil, line: 0)],
                                          body: nil,
                                          closure: { args in
                                              guard let analytics = self.analytics else { return NilAny }
                                              analytics.track(name:args[0] as! String)
                                              // wait till we know the event has been placed in the queue
                                              while analytics.hasUnsentEvents == false {
                                                  RunLoop.main.run(until: Date.distantPast)
                                              }
                                              //if flush {
                                                  analytics.flush()
                                                  // wait for flush to complete
                                                  while analytics.hasUnsentEvents {
                                                      analytics.flush()
                                                      RunLoop.main.run(until: Date.distantPast)
                                                  }
                                              //}
                                              return NilAny
                                          }),
                         closure: Environment(), isInitializer: false)
])
let analyticsInstance = LoxInstance(klass: analyticsClass)
return analyticsInstance
*/
