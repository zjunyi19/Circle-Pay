//
//  MoneyTrackViewController.swift
//  try
//
//  Created by Junyi Zhang on 3/11/20.
//  Copyright © 2020 Junyi Zhang. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseDatabase

class MoneyTrackViewController: UIViewController, canReceive, canReceiveBudget {
    

    @IBOutlet weak var AmountLabel: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    var budgetValue = 0.0
    var startDateValue = Date()
    var endDateValue = Date()
    var spending = 0.0
    var addbudget = 0.0
    
    func passBudgetBack(data: Double) {
        addbudget = data
        budgetValue += addbudget
        AmountLabel.text = "\(budgetValue)"
    }
    
    func passDataBack(data: Double) {
        spending = data
        budgetValue -= spending
        AmountLabel.text = "\(budgetValue)"
        if endDateValue < Date() {
            createAlert(title: "End Session", message: "The current session ends. Please start a new session.")
        }
        if budgetValue < 20 {
            AmountLabel.textColor = UIColor.red
            AmountLabel.font = AmountLabel.font.withSize(50)
            let content = UNMutableNotificationContent()
            content.title = "Circle Pay Warning"
            content.body = "You have \(budgetValue) left"
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "notifidentifier", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AmountLabel.text = "\(budgetValue)"
        if endDateValue < Date() {
            createAlert(title: "End Session", message: "The current session ends. Please start a new session.")
        }
    }
    
    @IBAction func FinishBtn(_ sender: Any) {
        let ref = Database.database().reference().child("claudia")
        ref.removeValue()
    }
    @IBAction func FinishtoSummary(_ sender: Any) {
        performSegue(withIdentifier: "ToSummary", sender: self)
    }
    
    @IBAction func addButton(_ sender: Any) {
        performSegue(withIdentifier: "toMoneySpent", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMoneySpent" {
            let vc = segue.destination as! MoneySpentViewController
            vc.delegate = self
        }
        if segue.identifier == "toAddBudget" {
            let vc = segue.destination as! AddBudgetViewController
            vc.delegate = self
        }
    }
 
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            self.performSegue(withIdentifier: "endSession", sender: self)
            
        
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    

}
