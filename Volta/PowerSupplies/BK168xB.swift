//
//  BK168xB.swift
//  Volta
//
//  Created by Neil Betham on 12/25/17.
//  Copyright © 2017 Neil Betham. All rights reserved.
//

import Foundation
import ORSSerial
import Dispatch

class BK168xB : NSObject, PowerSupply, ORSSerialPortDelegate {
    // USB Serial Port
    private var device: ORSSerialPort = ORSSerialPort() {
        willSet {
            device.close()
            device.delegate = nil
        }
        didSet {
            device.baudRate = 9600
            device.delegate = self
            device.shouldEchoReceivedData = true
            device.open()
            print("Opening: \(device.path)")
        }
    }
    private var connected: Bool = false
    
    // Internal state of the power supply
    private var voltage_setpoint: Float = 0
    private var current_setpoint: Float = 0
    private var voltage_value: Float = 0
    private var current_value: Float = 0
    private var supply_mode: PowerSupplyStatus = .ConstantVoltage
    
    // Event handlers
    private var delegate: PowerSupplyUpdateDelegate?
    
    init(_ device_: String) {
        super.init()
        bleh(device_)
    }
    
    private func bleh(_ path: String){
        if let port = ORSSerialPort(path: path){
            device = port
        } else {
            print("Failed to open serial port: \(path)")
        }
    }
    
    func set_voltage(set_point: Float) -> Bool {
        let command = String(format: "VOLT%@\r", float_to_string(convert_me: set_point))
        sendCommand(command: command, get: false)
        return true
    }
    
    func set_current(set_point: Float) -> Bool {
        let command = String(format: "CURR%@\r", float_to_string(convert_me: set_point))
        sendCommand(command: command, get: false)
        return true
    }
    
    func get_voltage() -> Float {
        return voltage_value
    }
    
    func get_current() -> Float {
        return current_value
    }
    
    func get_voltage_setpoint() -> Float {
        return voltage_setpoint
    }
    
    func get_current_set_point() -> Float {
        return current_setpoint
    }
    
    func get_constant_mode() -> PowerSupplyStatus {
        return supply_mode
    }
    
    func sync() -> Bool {
        sendCommand(command: "GETS", get: true)
        sleep(1)
        sendCommand(command: "GETD", get: true, command_length: 9)
        return true
    }
    
    func set_update_delegate(_ _delegate: PowerSupplyUpdateDelegate) {
        delegate = _delegate
    }
    
    private func sendCommand(command: String, get: Bool, command_length: Int = 6) {
        var full_command = command
        full_command.append("\r")
        if let command_data = full_command.data(using: .ascii){
            var packet_descriptor: ORSSerialPacketDescriptor?
            do {
                if get {
                    packet_descriptor = ORSSerialPacketDescriptor(regularExpression: try NSRegularExpression(pattern: "([0-9]{\(command_length)})\rOK", options: []), maximumPacketLength: 60, userInfo: command)
                } else {
                    packet_descriptor = ORSSerialPacketDescriptor(regularExpression: try NSRegularExpression(pattern: "OK\r", options: []), maximumPacketLength: 3, userInfo: command)
                }
            } catch {
                print("Regex error")
            }
            if let pd = packet_descriptor {
                let request = ORSSerialRequest(dataToSend: command_data, userInfo: command, timeoutInterval: 1, responseDescriptor: pd)
                device.send(request)
            }
        }
    }
    
    private func float_to_string(convert_me: Float) -> String {
        let whole_comp = Int(convert_me.rounded(.down))
        let fractional_comp = Int((convert_me * 10.0).rounded(.down)) - (whole_comp * 10)
        return String(format: "%02d%01d", whole_comp, fractional_comp)
    }
    
    private func string_to_float(convert_me: String, decimal_index: Int) -> Float {
        let whole_comp = convert_me[..<convert_me.index(convert_me.startIndex, offsetBy: decimal_index)]
        let fractional_comp = convert_me[convert_me.index(convert_me.startIndex, offsetBy: decimal_index)...]
        if var sum = Float(whole_comp){
            if let fractional_comp_conv = Float(fractional_comp){
                sum += fractional_comp_conv / pow(10.0, Float(fractional_comp.count))
                return sum
            }
        }
        return 0.0
    }
    
    private func parse_setting_update_from_supply(_ update: String) -> Bool {
        let resp = update
        if resp.count > 0 {
            let voltage_setpoint_resp = String(resp[..<resp.index(resp.startIndex, offsetBy: 3)])
            let current_setpoint_resp = String(resp[resp.index(resp.startIndex, offsetBy: 3)..<resp.index(resp.startIndex, offsetBy: 6)])
            
            voltage_setpoint = string_to_float(convert_me: voltage_setpoint_resp, decimal_index: 2)
            current_setpoint = string_to_float(convert_me: current_setpoint_resp, decimal_index: 2)
            return true
        }
        
        return false
    }
    
    private func parse_value_update_from_supply(_ update: String) -> Bool {
        let resp = update
        if resp.count > 0 {
            let voltage_setpoint_resp = String(resp[..<resp.index(resp.startIndex, offsetBy: 4)])
            let current_setpoint_resp = String(resp[resp.index(resp.startIndex, offsetBy: 4)..<resp.index(resp.startIndex, offsetBy: 8)])
            let mode_resp = String(resp[resp.index(resp.startIndex, offsetBy: 8)..<resp.index(resp.startIndex, offsetBy: 9)])
            
            voltage_value = string_to_float(convert_me: voltage_setpoint_resp, decimal_index: 2)
            current_value = string_to_float(convert_me: current_setpoint_resp, decimal_index: 2)
            
            if mode_resp == "0" {
                supply_mode = .ConstantVoltage
            } else {
                supply_mode = .ConstantCurrent
            }
            return true
        }
        
        return false
    }
    
    private func sendUpdateToDelegate() {
        if let del = delegate{
            DispatchQueue.main.async {
                del.handle_update(update: PowerSupplyUpdate(
                    voltage_: self.voltage_value,
                    current_: self.current_value,
                    voltage_setpoint_: self.voltage_setpoint,
                    current_setpoint_: self.current_setpoint,
                    status_: self.supply_mode
                ))
            }
        }
    }
    
    
    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        connected = false
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        connected = false
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        print("Port opened")
        connected = true
        let _ = sync()
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceiveResponse responseData: Data, to request: ORSSerialRequest) {
        let command = request.userInfo as! String
        let resp = String(data: responseData, encoding: .ascii)!

        switch command {
        case "GETS":
            let _ = parse_setting_update_from_supply(resp)
        case "GETD":
            let _ = parse_value_update_from_supply(resp)
        default:
            sync()
            print("\(command): \(resp)")
        }
        sendUpdateToDelegate()
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Serial port error: \(error.localizedDescription)")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
        print("Request: \(request.userInfo as! String): timed out")
    }
}
