//
//  MakePaymentViewController.swift
//  GoatLandscaping
//
//  Created by Jen Person on 8/21/18.
//  Copyright © 2018 Jen Person. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class MakePaymentViewController: UIViewController {

  // MARK: Properties
  lazy var db = Firestore.firestore()
  let paymentDownloader = PaymentDownloader()
  let sourceDownloader = SourceDownloader()
  var sources = [Source]()
  var selectedSource = 0
  var price = 202020
  
  // MARK: Outlets
  
  @IBOutlet weak var goatImageView: UIImageView!
  @IBOutlet weak var cardButton: UIButton!
  @IBOutlet weak var paymentDescriptionLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var payButton: UIButton!
  @IBOutlet weak var cardPickerView: UIPickerView!
  
  override func viewDidLoad() {
      super.viewDidLoad()
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePickerView))
    self.view.addGestureRecognizer(tapGestureRecognizer)
    cardButton.tintColor = UIColor.black
    cardPickerView.delegate = self
    cardPickerView.dataSource = self
    cardPickerView.isHidden = true
    
    mockPayments()
    downloadSources()
  }
  
  func downloadSources() {
    sourceDownloader.downloadSources { (sources, error) in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      self.sources = sources
      self.cardPickerView.reloadAllComponents()
      self.updateCardButton()
    }
  }
  
  func mockPayments() {
    let dollars = price/100
    let cents = price%100
    let priceText = String(format: "$%d.%02d", dollars, cents)
    priceLabel.text = priceText
    paymentDescriptionLabel.text = "2 acres of goat mowing"

  }
  
  func updateCardButton() {
    let source = sources[selectedSource]
    let brand = source.brand ?? ""
    let last4 = source.last4 ?? "0000"
    let title = "\(brand) \(last4)"
    cardButton.setTitle(title, for: .normal)
  }
  
  func makePayment(price: Int) {
    let source = sources[selectedSource].id
    paymentDownloader.makePayment(source: source, charge: price) { error in
      
      let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
        
      })
      let alertController = UIAlertController(title: "Success!", message: "payment complete", preferredStyle: .alert)
      alertController.addAction(okAction)
      if let error = error {
        alertController.title = "Error"
        alertController.message = error as! String
      }
      self.navigationController?.present(alertController, animated: true, completion:nil)
    }
    
    
  }
  
  @objc func hidePickerView() {
    cardPickerView.isHidden = true
  }

  
  @IBAction func didTapPayButton(_ sender: Any) {
    makePayment(price: price)
  }
  
  @IBAction func didTapCardButton(_ sender: Any) {
    cardPickerView.isHidden = false
  }
  
  
}

extension MakePaymentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return sources.count
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedSource = component
    updateCardButton()
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    let source = sources[component]
    let brand = source.brand ?? ""
    let last4 = source.last4 ?? "0000"
    let title = "\(brand) \(last4)"
    return title
  }
  
}
