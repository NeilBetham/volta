//
//  PowerSupply.swift
//  Volta
//
//  Created by Neil Betham on 12/25/17.
//  Copyright © 2017 Neil Betham. All rights reserved.
//

import Foundation

protocol PowerSupply {
    func set_voltage(set_point:Float) -> Bool
    func set_current(set_point:Float) -> Bool
    func set_output_on() -> Bool
    func set_output_off() -> Bool
    func get_voltage_setpoint() -> Float
    func get_current_set_point() -> Float
    func get_voltage() -> Float
    func get_current() -> Float
    func get_constant_mode() -> PowerSupplyStatus
    func sync() -> Bool
    
    func set_update_delegate(_ _delegate: PowerSupplyUpdateDelegate)
    func set_update_time(_ interval: Float)
    func set_enable_updates()
    func set_disable_updates()
}
