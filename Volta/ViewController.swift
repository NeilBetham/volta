//
//  ViewController.swift
//  Volta
//
//  Created by Neil Betham on 12/20/17.
//  Copyright © 2017 Neil Betham. All rights reserved.
//

import Cocoa
import USBDeviceSwift

class ViewController: NSViewController, PowerSupplyUpdateDelegate {
    var power_supply_interface: PowerSupply?
    var selected_control_port: String = ""
    
    @IBOutlet weak var serial_port_selector: NSPopUpButton!
    @IBOutlet weak var voltage_control: NSTextField!
    @IBOutlet weak var current_control: NSTextField!
    @IBOutlet weak var output_control: NSSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_control_port_menu()
        
        // Setup hooks for new devices
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbConnected), name: .SerialDeviceAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbDisconnected), name: .SerialDeviceRemoved, object: nil)
    }
    
    @IBAction func control_port_selected(_ sender: Any) {
        let selector: NSPopUpButton = sender as! NSPopUpButton
        if let selected_item = selector.selectedItem {
            if selected_item.title == "-" {
                return
            }
            selected_control_port = selected_item.title
            setup_power_supply()
        }
    }
    
    @IBAction func voltage_control_updated(_ sender: Any) {
        let tf = sender as! NSTextField
        let _ = power_supply_interface?.set_voltage(set_point: tf.floatValue)
        self.view.window?.makeFirstResponder(self.view.window?.contentView)
    }
    
    
    @IBAction func current_control_updated(_ sender: Any) {
        let tf = sender as! NSTextField
        if tf.floatValue < 0.1 {
            return
        }
        let _ = power_supply_interface?.set_current(set_point: tf.floatValue)
        self.view.window?.makeFirstResponder(self.view.window?.contentView)
    }

    @IBAction func output_selector_updated(_ sender: Any) {
        let of = sender as! NSSegmentedControl
        
        if let ps = self.power_supply_interface {
            if of.indexOfSelectedItem == 0 {
                let _ = ps.set_output_off()
            } else {
                let _ = ps.set_output_on()
            }
        }
        
    }
    
    func setup_control_port_menu() {
        serial_port_selector.removeAllItems()
        serial_port_selector.addItem(withTitle: "-")
    }
    
    func setup_power_supply(){
        power_supply_interface = BK168xB(selected_control_port)
        power_supply_interface?.set_update_delegate(self)
        power_supply_interface?.set_update_time(1)
        power_supply_interface?.set_enable_updates()
    }
    
    func handle_update(update: PowerSupplyUpdate) {
        let voltage_value_string = String(format: "%2.2f", update.voltage)
        if voltage_control?.stringValue != voltage_value_string {
            voltage_control?.stringValue = voltage_value_string
        }
        
        let current_value_string = String(format: "%2.2f", update.current)
        if current_control?.stringValue != current_value_string {
            current_control?.stringValue = current_value_string
        }

        if update.output == .On {
            output_control.selectSegment(withTag: 1)
        } else {
            output_control.selectSegment(withTag: 0)
        }
    }
    
    // getting connected device data
    @objc func usbConnected(notification: NSNotification) {
        guard let nobj = notification.object as? NSDictionary else {
            return
        }
        
        guard let device_info:SerialDevice = nobj["device"] as? SerialDevice else {
            return
        }
        
        print("Device added: \n \(device_info)")
        DispatchQueue.main.async {
            self.serial_port_selector.addItem(withTitle: device_info.path)
        }
    }
    
    // getting disconnected device id
    @objc func usbDisconnected(notification: NSNotification) {
        guard let nobj = notification.object as? NSDictionary else {
            return
        }
        
        guard let device_info:SerialDevice = nobj["id"] as? SerialDevice else {
            return
        }
        
        print("Device removed: \n \(device_info)")
        DispatchQueue.main.async {
            let index_to_remove = self.serial_port_selector.indexOfItem(withTitle: device_info.path)
            self.serial_port_selector.removeItem(at: index_to_remove)
        }
    }
}
