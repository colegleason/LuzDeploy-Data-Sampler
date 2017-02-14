//
//  UUIDRule.swift
//  LuzDeploy Data Sampler
//
//  Created by Cole Gleason on 2/10/17.
//  Copyright © 2017 Cole Gleason. All rights reserved.
//

import Foundation
import SwiftValidator

class UUIDRule : RegexRule {
    static let regex = "^(?i)[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
    
    convenience init(message : String = "Not a valid UUID"){
        self.init(regex: UUIDRule.regex, message : message)
    }
}

class PositiveIntRule : RegexRule {
    static let regex = "^[1-9]\\d*$"
    
    convenience init(message : String = "Must be a positive integer."){
        self.init(regex: PositiveIntRule.regex, message : message)
    }
}

class BeaconListRule : RegexRule {
    static let regex = "^\\s*\\d+(?:-\\d+)?\\s*(?:,\\s*\\d+(?:-\\d+)?\\s*)*$"
    
    convenience init(message : String = "Must be integers or integer ranges seperated by commas."){
        self.init(regex: BeaconListRule.regex, message : message)
    }
}
