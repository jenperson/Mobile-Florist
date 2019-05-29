//
//  RefundsViewController.swift
//  GoatLandscaping
//
//  Created by Jen Person on 3/7/19.
//  Copyright © 2019 Jen Person. All rights reserved.
//

import UIKit

class RefundsViewController: UIViewController {

  // MARK: Properties
  lazy var paymentDownloader = PaymentDownloader()
  lazy var authHandler = AuthHandler()
  var requests: [RefundRequest]? {
    didSet {
      refundsTableView.reloadData()
    }
  }
  
  // MARK: Outlets
  
  @IBOutlet weak var refundsTableView: UITableView!
  
  override func viewDidLoad() {
        super.viewDidLoad()
    authHandler.checkLoginStatus { user, moderator in
      guard let user = user else { return }
      self.paymentDownloader.downloadRefunds { (requests, error) in
          if let error = error {
            print(error)
            return
          }
          self.requests = requests
        }
      }
    }
  

}

extension RefundsViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let requests = requests else { return 0 }
    return requests.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "refundCell", for: indexPath) as! RefundsTableViewCell
    cell.refundRequest = requests?[indexPath.item]
    return cell
  }
  
  
}
