// Copyright 2021 Twilio Inc.

import Foundation
import SwiftCLI

func main() {
    let segment = CLI(name: "segmentcli",
                      version: "1.0.0",
                      description: "A command line utility to interact with and drive Segment",
                      commands: [
                        AuthCommand(),
                        ProfileGroup(),
                        ImportCommand(),
                        AnalyticsGroup(),
                        ScaffoldCommand(),
                        REPLCommand(),
                        EdgeFnGroup(),
                        SourcesGroup()
                      ])
    
    segment.globalOptions.append(useStagingKey)
    segment.globalOptions.append(specifiedProfileKey)
    
    segment.go()
}

main()
