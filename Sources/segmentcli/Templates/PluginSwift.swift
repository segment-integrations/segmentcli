let plugin_templates_swift = [plugin_swift]


let plugin_swift = """
//
//  {{filename}}
//  
//
//  Created by `segmentcli --plugin --swift -n {{name}}`.
//
//  Add this code to your project.  To apply this plugin to
//  the analytics timeline, it will also be necessary to add
//  the following code after you've created your Analytics
//  instance.
//
//  ```
//  analytics.add(plugin: {{name}}())
//  ```
//
//  This will add the {{name}} plugin such that events will
//  start flowing through it as they come in.
//
//  See the link below for more information:
//    https://segment.com/docs/connections/sources/catalog/libraries/mobile/swift-ios/#adding-a-plugin
//

import Foundation
import Segment

class {{name}}: EventPlugin {
    var type: PluginType = .enrichment
    
    var analytics: Analytics?
    
    func track(event: TrackEvent) -> TrackEvent? {
        return event
    }
    
    func identify(event: IdentifyEvent) -> IdentifyEvent? {
        return event
    }
    
    func screen(event: ScreenEvent) -> ScreenEvent? {
        return event
    }
    
    func group(event: GroupEvent) -> GroupEvent? {
        return event
    }
    
    func alias(event: AliasEvent) -> AliasEvent? {
        return event
    }
    
    func flush() {
        
    }
    
    func reset() {
        
    }
}
"""
