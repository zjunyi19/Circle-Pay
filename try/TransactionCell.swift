//
//  TransactionCell.swift
//  try
//
//  Created by Junyi Zhang on 4/16/20.
//  Copyright © 2020 Junyi Zhang. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseUI


class TransactionCell: UITableViewCell {

    @IBOutlet weak var receiptView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    func setTransaction(transaction: Transaction) {
        if (transaction.attribute == "-") {
            amountLabel.text = "- " + transaction.amount
            if transaction.receipt_url == "" {
                receiptView.isHidden = true
            }
            else {
                // Create a storage reference from the URL
                let gsReference = Storage.storage().reference(forURL: transaction.receipt_url)
                // Download the data, assuming a max size of 1MB (you can change this as necessary)
                gsReference.getData(maxSize: 15 * 1024 * 1024) { data, error in
                    if error != nil {
                    print(error)
                    // Uh-oh, an error occurred!
                  } else {
                    // Data for "images/island.jpg" is returned
                        print("try to set image")
                        let image = UIImage(data: data!)
                        self.receiptView.image = image
                  }
                }
            }
        }
        else {
            amountLabel.text = "+ " + transaction.amount
            amountLabel.textColor = UIColor.red
            // center
            receiptView.isHidden = true
        }
        
        locationLabel.text = transaction.location
        
//        // Reference to an image file in Firebase Storage
//        let reference = Storage.storage().reference(forURL: transaction.receipt_url)
//
//        // UIImageView in your ViewController
//        receiptView = self.imageView
//
//        // Placeholder image
//        let placeholderImage = UIImage(named: "placeholder.jpg")
//
//        // Load the image using SDWebImage
//        imageView?.sd_setImage(with: reference, placeholderImage: placeholderImage)
        
    }
    
}
