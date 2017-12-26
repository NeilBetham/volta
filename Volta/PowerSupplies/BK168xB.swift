//
//  BK168xB.swift
//  Volta
//
//  Created by Neil Betham on 12/25/17.
//  Copyright © 2017 Neil Betham. All rights reserved.
//

import Foundation
import PowerSupply

class BK168xB : PowerSupply {
    var device: string
    
    init(device_: string) {
        device = device_
    }
    
    func set_voltage(set_point: Float) -> Float {
        <#code#>
    }
    
    func set_current(set_point: Float) -> Float {
        <#code#>
    }
    
    func get_voltage() -> Float {
        <#code#>
    }
    
    func get_current() -> Float {
        <#code#>
    }
    
    func get_constant_mode() -> PowerSupplyStatus {
        <#code#>
    }
    
    func set_update_delegate(delegate: PowerSupplyUpdateDelegate) -> Bool {
        <#code#>
    }
    
    func enable_monitoring() -> Bool {
        <#code#>
    }
    
    func disable_monitoring() -> Bool {
        <#code#>
    }
}
