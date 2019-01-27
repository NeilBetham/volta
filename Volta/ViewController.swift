//
//  ViewController.swift
//  Volta
//
//  Created by Neil Betham on 12/20/17.
//  Copyright © 2017 Neil Betham. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, PowerSupplyUpdateDelegate {
    var control_port_enumerator: ControlPortEnumerator = ControlPortEnumerator()
    var power_supply_interface: PowerSupply?
    var selected_control_port: String = ""
    
    @IBOutlet weak var serial_port_selector: NSPopUpButton!
    @IBOutlet weak var voltage_control: NSTextField!
    @IBOutlet weak var current_control: NSTextField!
    @IBOutlet weak var output_control: NSSegmentedControl!
    
    @IBAction func control_port_selected(_ sender: Any) {
        let selector: NSPopUpButton = sender as! NSPopUpButton
        if let selected_item = selector.selectedItem{
            selected_control_port = String(format: "/dev/%@", selected_item.title)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_control_port_menu()
    }

    func setup_control_port_menu() {
        serial_port_selector.removeAllItems()
        control_port_enumerator.find_ports()
        serial_port_selector.addItems(withTitles: control_port_enumerator.get_ports())
    }
    
    func setup_power_supply(){
        power_supply_interface = BK168xB(selected_control_port)
        power_supply_interface?.set_update_delegate(self)
    }
    
    func handle_update(update: PowerSupplyUpdate) {
        voltage_control?.stringValue = String(format: "%2.2f", update.voltage)
        current_control?.stringValue = String(format: "%2.2f", update.current)
    }
}
