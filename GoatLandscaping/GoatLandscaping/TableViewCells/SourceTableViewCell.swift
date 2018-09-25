//
//  SourceTableViewCell.swift
//  GoatLandscaping
//
//  Created by Jen Person on 8/17/18.
//  Copyright © 2018 Jen Person. All rights reserved.
//

import UIKit

class SourceTableViewCell: UITableViewCell {

  // MARK: Properties
  var source: Source! {
    didSet {
      brandLabel.text = source.brand ?? ""
      last4Label.text = source.last4 ?? ""
      expLabel.text = "\(source.exp_month)/\(source.exp_year)"
    }
  }
  
  // MARK: Outlets
  
  @IBOutlet weak var brandLabel: UILabel!
  @IBOutlet weak var last4Label: UILabel!
  @IBOutlet weak var expLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
