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
  var recipient: String?
  var id: String?
  var customer: String?
  var refunded: Bool
  
  enum RefundStatus: String {
    case refunded = "refunded"
    case requested = "requested"
    case rejected = "rejected"
  }
  
  init(amount: Int, currency: String, paid: Bool, date: Date? = nil, recipient: String, id: String, customer: String, refunded: Bool) {
    self.amount = amount
    self.currency = currency
    self.paid = paid
    self.date = date
    self.recipient = recipient
    self.id = id
    self.customer = customer
    self.refunded = refunded
  }
  
  convenience init(documentSnapshot: QueryDocumentSnapshot) {
    let dictionary = documentSnapshot.data()
    let amount = dictionary[Keys.AMOUNT.rawValue] as? Int ?? 0
    let currency = dictionary[Keys.CURRENCY.rawValue] as? String ?? "usd"
    let outcome = dictionary[Keys.OUTCOME.rawValue] as? [String: Any] ?? [String: Any]()
    let recipient = dictionary[Keys.RECIPIENT.rawValue] as? String ?? "My Best Friend"
    let paid = outcome[Keys.PAID.rawValue] as? Bool ?? true
    let timestamp = dictionary[Keys.DATE.rawValue] as? Timestamp
    let date = timestamp?.dateValue()
    let id = dictionary[Keys.ID.rawValue] as? String ?? ""
    let customer = dictionary[Keys.CUSTOMER.rawValue] as? String ?? ""
    let refunded = dictionary[Keys.REFUNDED.rawValue] as? Bool ?? false
    self.init(amount: amount, currency: currency, paid: paid, date: date, recipient: recipient, id: id, customer: customer, refunded: refunded)
  }
}

enum Keys: String {
  case AMOUNT = "amount"
  case CURRENCY = "currency"
  case PAID = "paid"
  case OUTCOME = "outcome"
  case DATE = "date"
  case RECIPIENT = "recipient"
  case ID = "id"
  case CUSTOMER = "customer"
  case REFUNDED = "refunded"
}
