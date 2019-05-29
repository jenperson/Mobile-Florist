//
//  PaymentHistoryTableViewCell.swift
//  GoatLandscaping
//
//  Created by Jen Person on 9/18/18.
//  Copyright © 2018 Jen Person. All rights reserved.
//

import UIKit

class PaymentHistoryTableViewCell: UITableViewCell {

  // MARK: Properties
  
  var charge: Charge! {
    didSet {
      // default if no date is present
      dateLabel.text = "Sept 20, 2018"
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .medium
      dateFormatter.timeStyle = .none
      // US English Locale (en_US)
      dateFormatter.locale = Locale(identifier: "en_US")
      if let date = charge.date {
        let formattedDate = dateFormatter.string(from: (date))
        dateLabel.text = formattedDate
      }
      if let recipient = charge.recipient {
        recipientLabel.text = recipient
      }

      let dollars = charge.amount/100
      let cents = charge.amount%100
      let priceText = String(format: "$%d.%02d", dollars, cents)
      if charge.refunded == true {
        let italicsFont = UIFont(name: "Avenir-BookOblique", size: 14.0)!
        let attributedString = NSMutableAttributedString(string: priceText, attributes: [NSAttributedStringKey.font : italicsFont])
        totalLabel.attributedText = attributedString
      } else {
       totalLabel.text = priceText
      }

    }
  }
  
  // MARK: Outlets
  
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var totalLabel: UILabel!
  @IBOutlet weak var recipientLabel: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      self.layer.borderWidth = 2
      self.layer.borderColor = UIColor.gray.cgColor
    
  }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
