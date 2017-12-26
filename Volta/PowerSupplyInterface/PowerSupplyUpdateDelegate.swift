//
//  PowerSupplyUpdateDelegate.swift
//  Volta
//
//  Created by Neil Betham on 12/25/17.
//  Copyright © 2017 Neil Betham. All rights reserved.
//

import Foundation
import PowerSupplyUpdate

protocol PowerSupplyUpdateDelegate {
    func handle_update(update: PowerSupplyUpdate)
}
