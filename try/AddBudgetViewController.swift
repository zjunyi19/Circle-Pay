//
//  AddBudgetViewController.swift
//  try
//
//  Created by Junyi Zhang on 4/15/20.
//  Copyright © 2020 Junyi Zhang. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol canReceiveBudget {
    func passBudgetBack(data: Double)
}

class AddBudgetViewController: UIViewController {


    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var addBudgetTxt: UITextField!
    var delegate: canReceiveBudget?
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func submitBtn(_ sender: Any) {
        if let budgetValue = Double(addBudgetTxt.text!) {
            if budgetValue <= 0 {
                warningLabel.text = "Please enter a valid number!"
            } else {
                warningLabel.text = ""
                delegate?.passBudgetBack(data: budgetValue)
                
                // pass date to database
                
                let ref = Database.database().reference()
                ref.child("claudia").childByAutoId().setValue(["amount":self.addBudgetTxt.text, "location":"", "receipt_url":"", "attribute":"+"] as [String:Any])
                
                // dismiss current window
                dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            warningLabel.text = "Please enter a valid number!"
        }
        
    }
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        // push data
        
    }
    
}
