//
//  File.swift
//  
//
//  Created by Brandon Sneed on 12/8/21.
//

import Foundation
import Segment
import SwiftCSV
import JavaScriptCore
import SwiftCLI

func runJSInteractive(context jsContext: JSContext) {
    configureJavascriptRuntime(jsContext)
    print("Welcome to the Segment Javascript REPL.  Type :help for assistance.")
    
    var counter = 1
    let readQueue = DispatchQueue(label: "segmentcli.js.execution")
    readQueue.async {
        while true {
            autoreleasepool {
                let code = Input.readLine(prompt: "  \(counter)> ")
                if code.isEmpty == false {
                    if let result = jsContext.evaluateScript(code) {
                        if result.isUndefined == false {
                            print(result.description)
                        }
                    }
                }
                counter += 1
            }
        }
    }
    // don't have a good solution to knowing when async stuff is complete yet.
    while true {
        RunLoop.main.run(until: Date.distantPast)
    }
}

func runJSFile(path scriptFile: String, context jsContext: JSContext) {
    configureJavascriptRuntime(jsContext)
    
    if FileManager.default.fileExists(atPath: scriptFile) {
        do {
            let url = URL(fileURLWithPath: scriptFile)
            let code = try String(contentsOf: url)
            let readQueue = DispatchQueue(label: "segmentcli.js.execution")
            @Atomic var done = false
            readQueue.async {
                jsContext.evaluateScript(code)
                done = true
            }
            // don't have a good solution to knowing when async stuff is complete yet.
            while done == false {
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 30))
            }
        } catch {
            exitWithError(error.localizedDescription)
        }
    } else {
        exitWithError("\(scriptFile) does not exist.")
    }
}

func runJS(script: String, context jsContext: JSContext) {
    configureJavascriptRuntime(jsContext)
    do {
        let readQueue = DispatchQueue(label: "segmentcli.js.execution")
        @Atomic var done = false
        readQueue.async {
            jsContext.evaluateScript(script)
            done = true
        }
        // TODO: don't have a good solution to knowing when async stuff is complete yet.
        while done == false {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 30))
        }
    } catch {
        exitWithError(error.localizedDescription)
    }
}


func configureJavascriptRuntime(_ jsContext: JSContext) {
    // setup exception handling
    jsContext.exceptionHandler = { context, exception in
        if let exception = exception {
            print(exception.description)
        } else {
            print("Error: Unknown javascript error occurred.")
        }
    }
    
    // make a print() function.
    let js_print: @convention(block) (String) -> Void = { message in
        print(message)
    }
    jsContext.setObject(unsafeBitCast(js_print, to: AnyObject.self), forKeyedSubscript: "print" as (NSCopying & NSObjectProtocol)?)
    
    // make the Analytics class available.
    jsContext.setObject(JSAnalytics.self, forKeyedSubscript: "Analytics" as NSString)

    // make the Analytics class available.
    jsContext.setObject(JSCSV.self, forKeyedSubscript: "CSV" as NSString)
}

@objc protocol JSCSVExports: JSExport {
    init(path: String)
    func rowCount() -> Int
    func rowValueForColumnName(_ row: Int, _ columnName: String) -> String?
}

@objc public class JSCSV: NSObject, JSCSVExports {
    let csv: CSV?
    
    required init(path: String) {
        let url = URL(fileURLWithPath: path)
        do {
            self.csv = try CSV(url: url, delimiter: "|", encoding: .utf8, loadColumns: true)
        } catch {
            self.csv = nil
            print("Error: \(error)")
        }
    }
    
    func rowCount() -> Int {
        if let csv = csv {
            return csv.namedRows.count
        }
        return 0
    }
    
    func rowValueForColumnName(_ row: Int, _ columnName: String) -> String? {
        let result = csv?.namedRows[row][columnName]
        return result
    }
    
    
}

@objc protocol JSAnalyticsExports: JSExport {
    init(writeKey: String)
    func track(_ name: String, _ properties: [String: Any]?)
    func identify(_ userId: String, _ traits: [String: Any]?)
    func flush()
}

@objc public class JSAnalytics: NSObject, JSAnalyticsExports {
    let analytics: Analytics
    required init(writeKey: String) {
        self.analytics = Analytics(configuration: Configuration(writeKey: writeKey))
    }
    
    func track(_ name: String, _ properties: [String : Any]?) {
        analytics.track(name: name, properties: properties)
    }
    
    func identify(_ userId: String, _ traits: [String : Any]?) {
        analytics.identify(userId: userId, traits: traits)
    }
    
    func flush() {
        analytics.flush()
    }
}


/*
func configureInterpeterRuntime() {
    // Define CSV class
    Lox.define(name: "CSV", value: AnonymousCallable(arity: 1) { interpreter, args in
        let env = interpreter.environment
        guard let csvFile = args[0] as? String else { return NilAny }
        let reference = try? CSV(url: URL(fileURLWithPath: csvFile), delimiter: "|", encoding: .utf8, loadColumns: true)
        
        let csvClass = LoxClass(name: "CSV", superclass: nil, methods: [
            "rowCount": LoxFunction(name: "rowCount", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "rowCount", literal: nil, line: 0),
                                                  parameters: [],
                                                  body: nil,
                                                  closure: { args in
                                                      let value = Double(reference?.namedRows.count ?? 0)
                                                      return value
                                                  }),
                                    closure: Environment(enclosing: env), isInitializer: false),
            "rowValueForColumnName": LoxFunction(name: "rowValueForColumnName", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [
                                                    Token(type: .number, lexeme: "", literal: nil, line: 0),
                                                    Token(type: .string, lexeme: "", literal: nil, line: 0),
                                                  ],
                                                  body: nil,
                                                  closure: { args in
                                                      if let row = args[0] as? Double, let columnName = args[1] as? String {
                                                          let result = reference?.namedRows[Int(row)][columnName]
                                                          return result
                                                      }
                                                      return NilAny
                                                  }),
                                    closure: Environment(enclosing: env), isInitializer: false),

        ])
        let instance = LoxInstance(klass: csvClass)
        return instance
    })
    
    // Define Analytics class
    Lox.define(name: "Analytics", value: AnonymousCallable(arity: 1) { interpreter, args in
        let env = interpreter.environment
        guard let writeKey = args[0] as? String else { return NilAny }
        let reference = Analytics(configuration: Configuration(writeKey: writeKey).flushAt(1))

        let analyticsClass = LoxClass(name: "Analytics", superclass: nil, methods: [
            "track": LoxFunction(name: "track", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [
                                                    Token(type: .string, lexeme: "", literal: nil, line: 0),
                                                  ],
                                                  body: nil,
                                                  closure: { args in
                                                      guard let arg0 = args[0] as? String else { return NilAny }
                                                      guard arg0.isEmpty == false else { return NilAny }
                                                      reference.track(name:arg0)
                                                      return NilAny
                                                  }),
                                 closure: Environment(enclosing: env), isInitializer: false),
            "identify": LoxFunction(name: "identify", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [
                                                    Token(type: .string, lexeme: "", literal: nil, line: 0),
                                                  ],
                                                  body: nil,
                                                  closure: { args in
                                                      guard let arg0 = args[0] as? String else { return NilAny }
                                                      guard arg0.isEmpty == false else { return NilAny }
                                                      reference.identify(userId:arg0)
                                                      return NilAny
                                                  }),
                                 closure: Environment(enclosing: env), isInitializer: false),
            "screen": LoxFunction(name: "screen", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [
                                                    Token(type: .string, lexeme: "", literal: nil, line: 0),
                                                  ],
                                                  body: nil,
                                                  closure: { args in
                                                      guard let arg0 = args[0] as? String else { return NilAny }
                                                      guard arg0.isEmpty == false else { return NilAny }
                                                      reference.screen(title:arg0)
                                                      return NilAny
                                                  }),
                                 closure: Environment(enclosing: env), isInitializer: false),
            /*"screen": LoxFunction(name: "screen", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [
                                                    Token(type: .string, lexeme: "", literal: nil, line: 0),
                                                    Token(type: .string, lexeme: "", literal: nil, line: 0),
                                                  ],
                                                  body: nil,
                                                  closure: { args in
                                                      reference.screen(title:args[0] as! String, category: args[1] as? String)
                                                      return NilAny
                                                  }),
                                 closure: Environment(), isInitializer: false),*/
            "group": LoxFunction(name: "group", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [
                                                    Token(type: .string, lexeme: "", literal: nil, line: 0),
                                                  ],
                                                  body: nil,
                                                  closure: { args in
                                                      guard let arg0 = args[0] as? String else { return NilAny }
                                                      guard arg0.isEmpty == false else { return NilAny }
                                                      reference.group(groupId:arg0)
                                                      return NilAny
                                                  }),
                                 closure: Environment(enclosing: env), isInitializer: false),
            "alias": LoxFunction(name: "alias", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [
                                                    Token(type: .string, lexeme: "", literal: nil, line: 0),
                                                  ],
                                                  body: nil,
                                                  closure: { args in
                                                      guard let arg0 = args[0] as? String else { return NilAny }
                                                      guard arg0.isEmpty == false else { return NilAny }
                                                      reference.alias(newId:arg0)
                                                      return NilAny
                                                  }),
                                 closure: Environment(enclosing: env), isInitializer: false),
            "flush": LoxFunction(name: "flush", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [],
                                                  body: nil,
                                                  closure: { args in
                                                      reference.flush()
                                                      return NilAny
                                                  }),
                                 closure: Environment(enclosing: env), isInitializer: false),
            "reset": LoxFunction(name: "reset", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [],
                                                  body: nil,
                                                  closure: { args in
                                                      reference.reset()
                                                      return NilAny
                                                  }),
                                 closure: Environment(enclosing: env), isInitializer: false),

        ])
        let instance = LoxInstance(klass: analyticsClass)
        return instance
    })

}
*/
