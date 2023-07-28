//
//  File.swift
//  
//
//  Created by Brandon Sneed on 12/8/21.
//

import Foundation
import Segment
import Substrata
import SwiftCLI
import AnalyticsLive

var engine = JSEngine()

func hasPrefix(_ prefix: String) -> (String) -> Bool {
    return { value in value.hasPrefix(prefix) }
}

func runJSInteractive() {
    configureEngine()
    print("Welcome to the Segment Javascript REPL.  Type :help for assistance.")
    
    var counter = 1
    let readQueue = DispatchQueue(label: "segmentcli.js.execution")
    readQueue.async {
        while true {
            autoreleasepool {
                let input = Input.readLine(prompt: "  \(counter)> ")
                switch input {
                case _ where input.hasPrefix("< "):
                    break
                    
                case _ where input.hasPrefix(":quit"):
                    exit(0)
                    
                case _ where input.hasPrefix(":reset"):
                    engine = JSEngine()
                    configureEngine()
                    counter = 1
                    
                case _ where input.hasPrefix(":print"):
                    let variable = input.replacingOccurrences(of: ":print ", with: "")
                    if let value = engine.object(key: variable) {
                        print("\(variable) = \(String(describing: value))")
                    } else {
                        print("\(variable) = nil")
                    }
                    
                case _ where input.hasPrefix(":help"):
                    print(replHelpText)
                    
                default:
                    if input.isEmpty == false {
                        let result = engine.evaluate(script: input)
                        if result != nil {
                            print(result.debugDescription)
                        }
                        counter += 1
                    }
                }
            }
        }
    }
    // don't have a good solution to knowing when async stuff is complete yet.
    while true {
        RunLoop.main.run(until: Date.distantPast)
    }
}

func runJSFile(path scriptFile: String) {
    configureEngine()
    
    if FileManager.default.fileExists(atPath: scriptFile) {
        do {
            let url = URL(fileURLWithPath: scriptFile)
            let code = try String(contentsOf: url)
            let readQueue = DispatchQueue(label: "segmentcli.js.execution")
            @Atomic var done = false
            readQueue.async {
                engine.evaluate(script: code)
                done = true
            }
            // don't have a good solution to knowing when async stuff is complete yet.
            while done == false {
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 10))
            }
        } catch {
            exitWithError(error.localizedDescription)
        }
    } else {
        exitWithError("\(scriptFile) does not exist.")
    }
}

func runJS(script: String) {
    configureEngine()
    let readQueue = DispatchQueue(label: "segmentcli.js.execution")
    @Atomic var done = false
    readQueue.async {
        engine.evaluate(script: script)
        done = true
    }
    // TODO: don't have a good solution to knowing when async stuff is complete yet.
    while done == false {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 10))
    }
}


func configureEngine() {
    engine.errorHandler = { error in
        switch error {
        case .evaluationError(let s):
            print(s)
        default:
            print(error)
        }
    }
    
    // expose our classes
    try? engine.expose(name: "Analytics", classType: AnalyticsJS.self)
    
    // set the system analytics object.
    //engine.setObject(key: "analytics", value: AnalyticsJS(wrapping: self.analytics, engine: engine))
    
    // setup our enum for plugin types.
    engine.evaluate(script: EmbeddedJS.enumSetupScript)
    engine.evaluate(script: EmbeddedJS.edgeFnBaseSetupScript)

    
    //engine.expose(classType: JSCSV.self, name: "CSV")
    //engine.expose(classType: JSAnalytics.self, name: "Analytics")
    
    // set the system analytics object.
    //engine.setObject(key: "analytics", value: JSAnalytics(wrapping: self.analytics, engine: engine))
}


let replHelpText = """
The REPL (Read-Eval-Print-Loop) acts like an interpreter.  Valid statements,
expressions, and declarations are immediately compiled and executed.

Commands must be prefixed with a colon at the REPL prompt (:quit for example.)
Typing just a colon followed by return will switch to the LLDB prompt.

Type “< path” to read in code from a text file “path”.

Commands:
    help            -- This help text.
    reset           -- Perform a complete reset of the REPL.
    quit            -- Quit the Segment REPL.
    print <var>     -- Prints the value of <var>.

"""
