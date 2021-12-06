//
//  File.swift
//  
//
//  Created by Brandon Sneed on 12/3/21.
//

import Foundation
import SwiftCLI
import Spinner
import ColorizeSwift

class ProfileGroup: CommandGroup {
    let name = "profile"
    let shortDescription = "Work with stored profiles on this device"
    let children: [Routable] = [ProfileListCommand(), ProfileSetCommand(), ProfileDeleteCommand()]
    init() {}
}

class ProfileListCommand: Command {
    let name = "list"
    let shortDescription = "List stored profiles on this device"
    
    func execute() throws {
        let settings = Settings.load()
        print("Profiles stored on this device:\n")
        if let profiles = settings.profiles {
            for (profile, workspace) in profiles {
                print("    Profile: \(profile.italic().bold()), Workspace: \(workspace.slug.italic().bold())")
            }
        }
        print("\n")
    }
}

class ProfileDeleteCommand: Command {
    let name = "delete"
    let shortDescription = "Delete a stored profile from this device"
    
    @Param var profileName: String
    
    func execute() throws {
        print("Removing `\(profileName)` from stored profiles...")
        let settings = Settings.load()
        if var profiles = settings.profiles, let defaultProfile = settings.defaultProfile {
            profiles.removeValue(forKey: profileName)
            settings.profiles = profiles
            // set a new default if we just deleted it, or nil.
            if profileName == defaultProfile {
                settings.defaultProfile = profiles.first?.key
            }
            settings.save()
            print("Done.\n")
        }
    }
}

class ProfileSetCommand: Command {
    let name = "set"
    let shortDescription = "Set the default profile for this device"
    
    @Param var profileName: String
    
    func execute() throws {
        let settings = Settings.load()
        if let profiles = settings.profiles {
            let profile = profiles[profileName]
            if profile != nil {
                settings.defaultProfile = profileName
                settings.save()
                print("Default profile was set to `\(profileName)`.\n")
            } else {
                exitWithError(code: .commandFailed, message: "Profile named `\(profileName)` doesn't exist.")
            }
        }
    }
}

// MARK: - Global option for profile

let specifiedProfileKey = Key<String>("-p", "--profile", description: "Specify a profile name to use for this operation")
extension Command {
    var specifiedProfile: String? {
        return specifiedProfileKey.value
    }
    
    var currentWorkspace: Settings.Workspace? {
        var result: Settings.Workspace? = nil
        
        let settings = Settings.load()
        if let profile = self.specifiedProfile {
            result = settings.profiles?[profile]
        } else if let profile = settings.defaultProfile {
            result = settings.profiles?[profile]
        }
        return result
    }
}
