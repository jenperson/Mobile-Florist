//
//  Charge.swift
//  GoatLandscaping
//
//  Created by Jen Person on 8/22/18.
//  Copyright © 2018 Jen Person. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class Charge {
 
  var amount: Int
  var currency: String?
  var paid = true
  var date: Date?
  
  fileprivate enum Keys: String {
    case AMOUNT = "amount"
    case CURRENCY = "currency"
    case PAID = "paid"
    case OUTCOME = "outcome"
    case DATE = "date"
  }
  
  init(amount: Int, currency: String? = nil, paid: Bool?, date: Date? = nil) {
    self.amount = amount
    self.currency = currency
    self.paid = paid ?? true
    self.date = date
  }
  
  convenience init(documentSnapshot: QueryDocumentSnapshot) {
    let dictionary = documentSnapshot.data()
    let amount = dictionary[Keys.AMOUNT.rawValue] as? Int ?? 0
    let currency = dictionary[Keys.CURRENCY.rawValue] as? String ?? "usd"
    let outcome = dictionary[Keys.OUTCOME.rawValue] as? [String: Any] ?? [String: Any]()
    let paid = outcome[Keys.PAID.rawValue] as? Bool ?? true
    let date = dictionary[Keys.DATE.rawValue] as? Date
    self.init(amount: amount, currency: currency, paid: paid, date: date)
  }
}
