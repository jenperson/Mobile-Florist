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
  lazy var paymentDownloader = PaymentDownloader()
  lazy var sourceDownloader = SourceDownloader()
  var sources: [Source]? {
    didSet {
      self.cardPickerView.reloadAllComponents()
      self.updateCardButton()
    }
  }
  var selectedSource = 0
  var price = 5500 {
    didSet {
      mockPayments()
    }
  }
  
  // MARK: Outlets
  
  @IBOutlet weak var goatImageView: UIImageView!
  @IBOutlet weak var cardButton: UIButton!
  @IBOutlet weak var paymentDescriptionLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var payButton: UIButton!
  @IBOutlet weak var cardPickerView: UIPickerView!
  @IBOutlet weak var dimmedOverlay: UIView!
  @IBOutlet weak var recipientNameTextField: UITextField!
  
  override func viewDidLoad() {
      super.viewDidLoad()
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePickerView))
    self.view.addGestureRecognizer(tapGestureRecognizer)
    cardButton.tintColor = UIColor.black
    cardPickerView.isHidden = true
    configureOverlay()
    mockPayments()
    downloadSources()
  }
  
  // MARK: View Configuration
  
  func configureOverlay() {
    let captureTaps = UITapGestureRecognizer(target: self, action: #selector(hidePickerView))
    captureTaps.cancelsTouchesInView = true
    dimmedOverlay.addGestureRecognizer(captureTaps)
    dimmedOverlay.isHidden = true
  }
  
  func mockPayments() {
    paymentDescriptionLabel.text = "2 dozen roses"
    if price == 0 {
      priceLabel.text = "PAID"
      return
    }
    let dollars = price/100
    let cents = price%100
    let priceText = String(format: "$%d.%02d", dollars, cents)
    priceLabel.text = priceText
  }
  
  func updateCardButton() {
    guard let sources = sources else { return }
    let source = sources[selectedSource]
    let brand = source.brand ?? ""
    let last4 = source.last4 ?? "0000"
    let title = "\(brand) \(last4)"
    cardButton.setTitle(title, for: .normal)
  }
  
  @objc func hidePickerView() {
    cardPickerView.isHidden = true
    dimmedOverlay.isHidden = true
  }
  
  // MARK: Payment Management
  
  func downloadSources() {
    sourceDownloader.downloadSources { (sources, error) in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      self.sources = sources

    }
  }
  
  func makePayment(price: Int) {
    let source = sources?[selectedSource].id
    let recipient: String? = recipientNameTextField.text
    print(recipient ?? "no recipient")
    paymentDownloader.makePayment(source: source, charge: price, recipient: recipient) { error in
      
      let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
        self.recipientNameTextField.text = ""
        self.price = 0
      })
      let alertController = UIAlertController(title: "Success!", message: "payment complete", preferredStyle: .alert)
      alertController.addAction(okAction)
      if let error = error {
        alertController.title = "Error"
        alertController.message = error as? String
      }
      self.navigationController?.present(alertController, animated: true, completion:nil)
      // re-enable pay button upon completion
      self.payButton.isEnabled = true
    }
  }
  
  // MARK: Actions
  
  @IBAction func didTapPayButton(_ sender: Any) {
    // temporarily disable pay button to prevent double charge
    payButton.isEnabled = false
    makePayment(price: price)
  }
  
  @IBAction func didTapCardButton(_ sender: Any) {
    dimmedOverlay.isHidden = false
    cardPickerView.isHidden = false
  }
  
  
}

extension MakePaymentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return sources?.count ?? 0
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedSource = row
    updateCardButton()
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    guard let sources = sources else { return "" }
    let source = sources[row]
    let brand = source.brand ?? ""
    let last4 = source.last4 ?? "0000"
    let title = "\(brand) \(last4)"
    return title
  }
  
}
