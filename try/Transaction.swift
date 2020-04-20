//
//  Transaction.swift
//  try
//
//  Created by Junyi Zhang on 4/16/20.
//  Copyright © 2020 Junyi Zhang. All rights reserved.
//

import Foundation
import UIKit

class Transaction {
    var location: String
    var amount: String
    var receipt_url: String
    var attribute: String
    //var image: UIImage
    init(amount: String, location: String, receipt_url: String, attribute: String) {
        //self.image = image
        self.amount = amount
        self.location = location
        self.receipt_url = receipt_url
        self.attribute = attribute
        
    }
}
