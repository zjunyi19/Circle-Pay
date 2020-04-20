//
//  MoneySpentViewController.swift
//  try
//
//  Created by Junyi Zhang on 3/11/20.
//  Copyright © 2020 Junyi Zhang. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import CoreLocation
import MapKit
import FirebaseDatabase
import FirebaseStorage

protocol canReceive {
    func passDataBack(data: Double)
}
class CellClass: UITableViewCell {
    
}

class MoneySpentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, canReceiveAddress, SFSpeechRecognizerDelegate {
    @IBOutlet weak var receiptView: UIImageView!
    @IBOutlet weak var locationTxt: UITextField!
    @IBOutlet weak var warningLabel2: UILabel!
    @IBOutlet weak var checkView: UIImageView!
    @IBOutlet weak var activitySpinner: UILabel!
    var delegate:canReceive?
    @IBOutlet weak var spendingTxt: UITextField!
    var spendingValueFinal = 0.00
    @IBOutlet weak var warningLabel: UILabel!
    var imagePicker:ImagePicker!
    func passDataBack(data: String) {
        locationTxt.text = "\(data)"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.numberStyle = .spellOut
        activitySpinner.isHidden = true
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        checkView.isHidden = true
        requestPermission()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapScreen" {
            let vc = segue.destination as! MapScreen
            vc.delegate = self
        }
        
    }
   
    // send data
    @IBAction func BackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SubmitClicked(_ sender: Any) {
        var pass = true
        if let spendingValue = Double(spendingTxt.text!) {
            if spendingValue <= 0 {
                warningLabel.text = "Please enter a valid number!"
                pass = false
            }
        }
        else {
            warningLabel.text = "Please enter a number."
            pass = false
        }
        if let text = locationTxt.text, text.isEmpty {
            warningLabel2.text = "Please enter a valid address!"
            pass = false
        }
        
        if pass {
            var spendingValue = Double(spendingTxt.text!) ?? 0
            warningLabel.text = ""
            warningLabel2.text = ""
            delegate?.passDataBack(data: spendingValue)
            
            // push data to database
            if receiptView.image == checkView.image {
                let ref = Database.database().reference()
                ref.child("claudia").childByAutoId().setValue(["amount":self.spendingTxt.text, "location":self.locationTxt.text, "receipt_url":"", "attribute":"-"] as [String:Any])
            }
            else {
                // push image to storage
                var img_url = ""
                var file_name = randomString(length: 6)
                file_name = "claudia/" + file_name + ".png"
                let storageRef = Storage.storage().reference().child(file_name)
                let imgData = receiptView.image?.pngData()
                let metaData = StorageMetadata()
                metaData.contentType = "imge/png"
                storageRef.putData(imgData!, metadata: metaData) { (metadata, err) in
                    if err == nil{
                        print("error in save img")
                        storageRef.downloadURL(completion: { (url, error) in
                            if error != nil{
                                print("Failed to download url:", error!)
                                return
                            } else {
                                //Do something with url
                                print("success download url")
                                img_url = url?.absoluteString ?? ""
                                print(url!)
                                print(img_url)
                                // push data to database
                                let ref = Database.database().reference()
                                ref.child("claudia").childByAutoId().setValue(["amount":self.spendingTxt.text, "location":self.locationTxt.text, "receipt_url":img_url, "attribute":"-"] as [String:Any])
                            }
                        })
                    } else {
                        print("error in save image")
                    }
                }
            }
            // dismiss current window
            dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func importImage(_ sender: UIButton) {
        self.imagePicker.present(from:sender)
    }
    

    //******************************************//
    
    // record number
    @IBOutlet weak var btn_start: UIButton!
    let audioEngin = AVAudioEngine()
    let speechReconizer:SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task : SFSpeechRecognitionTask!
    var isStart: Bool = false
    let numberFormatter = NumberFormatter()
    func requestPermission() {
        self.btn_start.isEnabled = false
        SFSpeechRecognizer.requestAuthorization { (authState) in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    self.btn_start.isEnabled = true
                } else if authState == .denied {
                    self.alertView(message: "User denied the permission.")
                } else if authState == .notDetermined {
                    self.alertView(message: "In user phone, there is no speech recognization.")
                } else if authState == .restricted {
                    self.alertView(message: "User has been restricted for using the speech recognization.")
                }
            }
        }
    }
    
    @IBAction func btn_start_stop(_ sender: Any) {
        isStart = !isStart
        
        if isStart {
            startSpeechRecognization()
            btn_start.tintColor = .systemGreen
            activitySpinner.isHidden = false
        } else {
            cancelSpeechRecognization()
            btn_start.tintColor = .systemOrange
            activitySpinner.isHidden = true
        }
    }
    func startSpeechRecognization(){
        let node = audioEngin.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngin.prepare()
        do {
            try audioEngin.start()
        } catch let error {
            alertView(message: "Error comes here for starting the audio listner = \(error.localizedDescription)")
        }
        
        guard let myRecognization = SFSpeechRecognizer() else {
            self.alertView(message: "Recognization is not allowed on your device.")
            return
        }
        if !myRecognization.isAvailable {
            self.alertView(message: "Recognization is free right now. Please try it later some time.")
        }
        task = speechReconizer?.recognitionTask(with: request, resultHandler: { (response, error) in
            guard let response = response else {
                if error != nil {
                    self.alertView(message: error?.localizedDescription ?? "")
                } else {
                    self.alertView(message: "Problem is giving the response")
                }
                return
            }
            let message = response.bestTranscription.formattedString
            self.spendingTxt.text = message
            
        })
    }
    
    func cancelSpeechRecognization(){
        task.finish()
        task.cancel()
        task = nil
        request.endAudio()
        audioEngin.stop()
        audioEngin.inputNode.removeTap(onBus: 0)
    }
    
    func alertView(message: String) {
        let controller = UIAlertController.init(title: "Error occurred!", message:message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            controller.dismiss(animated: true, completion: nil)
        }))
        self.present(controller, animated: true, completion: nil)
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    //******************************************//
    
    @IBOutlet weak var btnSelectCategory: UIButton!
    let transparentView = UIView()
    let tableView = UITableView()
    var category = ""
    var selectedButton = UIButton()
    
    var dataSource = [String]()
    @IBAction func onclickSelectCategory(_ sender: Any) {
        dataSource = ["Food", "Entertainment", "Grocery", "Transportation", "Travel", "Education"]
        selectedButton = btnSelectCategory
        addTransparentView(frames: btnSelectCategory.frame)
    }
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count * 50))
        }, completion: nil)
    }
    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    
}
extension MoneySpentViewController:ImagePickerDelegate{
    func didSelect(image: UIImage?) {
        self.receiptView.image = image
    }
}

extension MoneySpentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
        category = dataSource[indexPath.row]
        removeTransparentView()
    }
}
