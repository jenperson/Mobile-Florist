//
//  RefundsTableViewCell.swift
//  GoatLandscaping
//
//  Created by Jen Person on 3/7/19.
//  Copyright © 2019 Jen Person. All rights reserved.
//

import UIKit

class RefundsTableViewCell: UITableViewCell {

  // MARK: Outlets
  
  @IBOutlet weak var amountRequestedLabel: UILabel!
  @IBOutlet weak var dateRequestedLabel: UILabel!
  @IBOutlet weak var customerLabel: UILabel!
  
  
  var refundRequest: RefundRequest! {
    didSet {
      // default if no date is present
      dateRequestedLabel.text = "Sept 20, 2018"
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .medium
      dateFormatter.timeStyle = .none
      // US English Locale (en_US)
      dateFormatter.locale = Locale(identifier: "en_US")
      if let date = refundRequest.userRequestedAt {
        let formattedDate = dateFormatter.string(from: date)
        dateRequestedLabel.text = formattedDate
      }
      if let customer = refundRequest.email {
        customerLabel.text = customer
      }
      
      let dollars = refundRequest.amount/100
      let cents = refundRequest.amount%100
      let priceText = String(format: "$%d.%02d", dollars, cents)
      amountRequestedLabel.text = priceText
      
    }
  }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  
  @IBAction func didTapApprove(_ sender: UIButton) {
    PaymentDownloader().approveRefund(refundRequest: refundRequest)
  }
  
}
