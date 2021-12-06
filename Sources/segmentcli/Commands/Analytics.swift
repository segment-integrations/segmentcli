//
//  File.swift
//  
//
//  Created by Brandon Sneed on 12/6/21.
//

import Foundation
import SwiftCLI
import Segment
import Spinner

class AnalyticsGroup: CommandGroup {
    let name = "analytics"
    let shortDescription = "Send custom crafted events to Segment"
    let children: [Routable] = [AnalyticsTrackCommand(),
                                AnalyticsIdentifyCommand(),
                                AnalyticsScreenCommand(),
                                AnalyticsGroupCommand(),
                                AnalyticsAliasCommand(),
                                AnalyticsResetCommand()]
    init() {}
}

let keyValueValidation = Validation<String>.custom("Key/Value pairs must be separated by an equal sign, ie: \"key=value\"") {
    $0.contains("=")
}

func paramArryToDictionary(_ params: [String]) -> [String: Any] {
    var result = [String: Any]()
    for param in params {
        var parts = param.components(separatedBy: "=")
        // first thing to the left of an = is our key
        let key = parts[0]; parts.removeFirst()
        // in case there was additional ='s in the string, combine it all back
        // and assume this was intentional for the value.
        let value = parts.joined(separator: "=")
        
        // now try to figure out the type of the value so we can type it appropriately
        var typedValue: Any
        if let n = Decimal(string: value) {
            // it's a number of some kind
            typedValue = n
        } else if let b = Bool(input: value) {
            // it's a boolean value
            typedValue = b
        } else {
            // nothing we can do, so it's a string at the end.
            typedValue = value
        }
        
        result[key] = typedValue
    }
    return result
}

class AnalyticsTrackCommand: Command {
    let name = "track"
    let shortDescription = "Send a track event to Segment"
    
    @Param var writeKey: String
    @Param var eventName: String
    
    @CollectedParam(minCount: 0, validation: keyValueValidation) var properties: [String]
    
    func execute() throws {
        let spinner = Spinner(.dots, "Sending track event to Segment ...")
        spinner.start()
        
        let config = Configuration(writeKey: writeKey)
        config.flushAt(1)
        
        let analytics = Analytics(configuration: config)
        executeAndWait { semaphore in
            analytics.track(name: eventName, properties: paramArryToDictionary(properties))
            // wait for the event to enter the system
            while analytics.hasUnsentEvents == false {
                RunLoop.main.run(until: Date.distantPast)
            }
            // wait for it to exit
            while analytics.hasUnsentEvents {
                RunLoop.main.run(until: Date.distantPast)
            }
            semaphore.signal()
        }
        
        spinner.stop()
        print("Event `\(eventName)` sent!\n")
    }
}

class AnalyticsIdentifyCommand: Command {
    let name = "identify"
    let shortDescription = "Send an identify event to Segment"
    
    @Param var writeKey: String
    @Param var userID: String
    
    @CollectedParam(minCount: 0, validation: keyValueValidation) var traits: [String]
    
    func execute() throws {
        let spinner = Spinner(.dots, "Sending identify event to Segment ...")
        spinner.start()
        
        let config = Configuration(writeKey: writeKey)
        config.flushAt(1)
        
        let analytics = Analytics(configuration: config)
        executeAndWait { semaphore in
            analytics.identify(userId: userID, traits: paramArryToDictionary(traits))
            // wait for the event to enter the system
            while analytics.hasUnsentEvents == false {
                RunLoop.main.run(until: Date.distantPast)
            }
            // wait for it to exit
            while analytics.hasUnsentEvents {
                RunLoop.main.run(until: Date.distantPast)
            }
            semaphore.signal()
        }
        
        spinner.stop()
        print("Identify Event for `\(userID)` sent!\n")
    }
}

class AnalyticsScreenCommand: Command {
    let name = "screen"
    let shortDescription = "Send a screen event to Segment"
    
    func execute() throws {
    }
}

class AnalyticsGroupCommand: Command {
    let name = "group"
    let shortDescription = "Send a group event to Segment"
    
    func execute() throws {
    }
}

class AnalyticsAliasCommand: Command {
    let name = "alias"
    let shortDescription = "Send an alias event to Segment"
    
    func execute() throws {
    }
}

class AnalyticsResetCommand: Command {
    let name = "reset"
    let shortDescription = "Resets any stored data like anonID, userID, etc"
    
    func execute() throws {
    }
}

