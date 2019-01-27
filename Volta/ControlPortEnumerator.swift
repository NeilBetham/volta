//
//  ControlPortEnumerator.swift
//  Volta
//
//  Created by Neil Betham on 1/26/19.
//  Copyright © 2019 Neil Betham. All rights reserved.
//

import Foundation

class ControlPortEnumerator {
    private var ports: Array<String> = Array()
    
    init() {}
    
    public func find_ports() {
        do {
            for file in try FileManager.default.contentsOfDirectory(atPath: "/dev/") {
                if file.starts(with: "cu.") {
                    ports.append(file)
                }
            }
        } catch {
            print("Error getting serial ports")
        }
    }
    
    public func get_ports() -> [String] {
        return ports
    }
}
