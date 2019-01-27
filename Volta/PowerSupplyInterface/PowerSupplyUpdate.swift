//
//  PowerSupplyUpdate.swift
//  Volta
//
//  Created by Neil Betham on 12/25/17.
//  Copyright © 2017 Neil Betham. All rights reserved.
//

import Foundation

enum PowerSupplyStatus {
    case ConstantCurrent
    case ConstantVoltage
}

class PowerSupplyUpdate {
    init(voltage_: Float, current_: Float, voltage_setpoint_: Float, current_setpoint_: Float, status_: PowerSupplyStatus) {
        voltage = voltage_
        current = current_
        voltage_setpoint = voltage_setpoint_
        current_setpoint = current_setpoint_
        status = status_
    }
    
    public private(set) var voltage: Float = 0
    public private(set) var current: Float = 0
    public private(set) var voltage_setpoint: Float = 0
    public private(set) var current_setpoint: Float = 0
    public private(set) var status: PowerSupplyStatus = .ConstantVoltage
}
