//
//  File.swift
//  
//
//  Created by Brandon Sneed on 12/8/21.
//

import Foundation
import Segment

func configureInterpeterRuntime() {
    Lox.define(name: "Analytics", value: AnonymousCallable(arity: 1) { interpreter, args in
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
                                                      reference.track(name:args[0] as! String)
                                                      return NilAny
                                                  }),
                                 closure: Environment(), isInitializer: false),
            "identify": LoxFunction(name: "identify", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [
                                                    Token(type: .string, lexeme: "", literal: nil, line: 0),
                                                  ],
                                                  body: nil,
                                                  closure: { args in
                                                      reference.identify(userId:args[0] as! String)
                                                      return NilAny
                                                  }),
                                 closure: Environment(), isInitializer: false),
            "screen": LoxFunction(name: "screen", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [
                                                    Token(type: .string, lexeme: "", literal: nil, line: 0),
                                                  ],
                                                  body: nil,
                                                  closure: { args in
                                                      reference.screen(title:args[0] as! String)
                                                      return NilAny
                                                  }),
                                 closure: Environment(), isInitializer: false),
            "screen": LoxFunction(name: "screen", declaration:
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
                                 closure: Environment(), isInitializer: false),
            "group": LoxFunction(name: "group", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [
                                                    Token(type: .string, lexeme: "", literal: nil, line: 0),
                                                  ],
                                                  body: nil,
                                                  closure: { args in
                                                      reference.group(groupId:args[0] as! String)
                                                      return NilAny
                                                  }),
                                 closure: Environment(), isInitializer: false),
            "alias": LoxFunction(name: "alias", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [
                                                    Token(type: .string, lexeme: "", literal: nil, line: 0),
                                                  ],
                                                  body: nil,
                                                  closure: { args in
                                                      reference.alias(newId:args[0] as! String)
                                                      return NilAny
                                                  }),
                                 closure: Environment(), isInitializer: false),
            "flush": LoxFunction(name: "flush", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [],
                                                  body: nil,
                                                  closure: { args in
                                                      reference.flush()
                                                      return NilAny
                                                  }),
                                 closure: Environment(), isInitializer: false),
            "reset": LoxFunction(name: "reset", declaration:
                                    Stmt.Function(name: Token(type: .fun, lexeme: "", literal: nil, line: 0),
                                                  parameters: [],
                                                  body: nil,
                                                  closure: { args in
                                                      reference.reset()
                                                      return NilAny
                                                  }),
                                 closure: Environment(), isInitializer: false),

        ])
        let analyticsInstance = LoxInstance(klass: analyticsClass)
        return analyticsInstance
    })

}
