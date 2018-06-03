//
//  LaunchViewController.swift
//  Lander
//
//  Created by Michael Skiles on 5/31/18.
//  Copyright © 2018 Michael Skiles. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    @IBOutlet weak var impulseTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        impulseTextField.text = Settings.instance.initialImpulse.description
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editedImpulse(_ sender: UITextField) {
        guard let text = sender.text else {
            return
        }
        
        if let impulse = Double(text) {
            Settings.instance.initialImpulse = impulse
        }
        print("Edited impulse")
    }
    
    func updateImpulse() {
        guard let text = impulseTextField.text else {
            return
        }
        
        if let impulse = Double(text) {
            Settings.instance.initialImpulse = impulse
        }
        print("Edited impulse")
    }
    
    @IBAction func backgroundTouched(_ sender: UIControl) {
        impulseTextField.resignFirstResponder()
        updateImpulse()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
