//
//  ShowDetailViewController.swift
//  try
//
//  Created by Zhenyang gong on 4/19/20.
//  Copyright © 2020 Junyi Zhang. All rights reserved.
//

import UIKit
import FirebaseStorage

class ShowDetailViewController: UIViewController {

    @IBOutlet weak var receipt_view: UIImageView!
    var url_string = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("show detail")
        print(url_string)
        // Create a storage reference from the URL
        let gsReference = Storage.storage().reference(forURL: url_string)
        // Download the data, assuming a max size of 1MB (you can change this as necessary)
        gsReference.getData(maxSize: 15 * 1024 * 1024) { data, error in
            if error != nil {
            print(error)
            // Uh-oh, an error occurred!
          } else {
            // Data for "images/island.jpg" is returned
                print("try to set image")
                let image = UIImage(data: data!)
                self.receipt_view.image = image
          }
        }
        // Do any additional setup after loading the view.
    }


}
