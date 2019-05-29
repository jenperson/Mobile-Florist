//
//  PaymentHistoryViewController.swift
//  GoatLandscaping
//
//  Created by Jen Person on 9/18/18.
//  Copyright © 2018 Jen Person. All rights reserved.
//

import UIKit

class PaymentHistoryViewController: UIViewController {

  // MARK: Properties
  lazy var paymentDownloader = PaymentDownloader()
  var charges: [Charge]? {
    didSet {
      payHistoryTableView.reloadData()
    }
  }
  let payCell = "payCell"
  var userId: String?
  lazy var authHandler = AuthHandler()
  
  // MARK: Outlets
  
  @IBOutlet weak var payHistoryTableView: UITableView!
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      authHandler.checkLoginStatus { user, moderator in
        guard let user = user else { return }
        self.userId = user.uid
        self.paymentDownloader.downloadPayments { (charges, err) in
          if let err = err {
            print(err)
            return
          }
          self.charges = charges
        }
      }
    }
  
  func requestRefund(charge: Charge) {
    // make sure there is a user signed in

  }

}

extension PaymentHistoryViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let charges = charges else { return 0 }
    return charges.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: payCell, for: indexPath) as! PaymentHistoryTableViewCell
    guard let charges = charges else { return cell }
    cell.charge = charges[indexPath.item]
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  // swiping available for refunds
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    print(charges ?? "no charges")
    guard let charges = self.charges, let userId = userId else { return nil }
    let charge = charges[indexPath.item]
    return [UITableViewRowAction.init(style: .default, title: "Request Refund", handler: { (action, indexpath) in
      self.paymentDownloader.requestRefund(charge: charge, amount: charge.amount, userId: userId) { (error) in
        if let error = error {
          print(error)
        }
      }
    })]
  }
  
}
