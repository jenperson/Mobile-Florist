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
  let paymentDownloader = PaymentDownloader()
  var charges = [Charge]()
  let payCell = "payCell"
  
  // MARK: Outlets
  
  @IBOutlet weak var payHistoryTableView: UITableView!
  
  
    override func viewDidLoad() {
        super.viewDidLoad()

      paymentDownloader.downloadPayments { (charges, err) in
        if let err = err {
          print(err)
          return
        }
        self.charges = charges
        self.payHistoryTableView.reloadData()
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension PaymentHistoryViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return charges.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: payCell, for: indexPath) as! PaymentHistoryTableViewCell
    cell.charge = charges[indexPath.item]
    return cell
  }
  
  
}
