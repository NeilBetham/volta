//
//  PowerSupply.swift
//  Volta
//
//  Created by Neil Betham on 12/25/17.
//  Copyright © 2017 Neil Betham. All rights reserved.
//

import Foundation
import PowerSupplyUpdateDelegate
import PowerSupplyUpate

protocol PowerSupply {
    func set_voltage(set_point:Float) -> Float
    func set_current(set_point:Float) -> Float
    func get_voltage() -> Float
    func get_current() -> Float
    func get_constant_mode() -> PowerSupplyStatus
    func set_update_delegate(delegate: PowerSupplyUpdateDelegate) -> Bool
    func enable_monitoring() -> Bool
    func disable_monitoring() -> Bool
}
