//
//  RefundRequest.swift
//  GoatLandscaping
//
//  Created by Jen Person on 3/7/19.
//  Copyright © 2019 Jen Person. All rights reserved.
//

import Foundation
import Firebase

class RefundRequest: Charge {
  
  var approvedAt: Date?
  var requesterUserId: String?
  var userRequestedAt: Date?
  var email: String?
  var key: String?
  

  
  init(amount: Int, currency: String, paid: Bool, date: Date?, recipient: String, id: String, customer: String, refunded: Bool, approvedAt: Date?, requesterUserId: String, userRequestedAt: Date?, email: String, key: String) {
    super.init(amount: amount, currency: currency, paid: paid, date: date, recipient: recipient, id: id, customer: customer, refunded: refunded)
    self.approvedAt = approvedAt
    self.requesterUserId = requesterUserId
    self.userRequestedAt = userRequestedAt
    self.email = email
    self.key = key
  }
  
  convenience init(documentSnapshot: QueryDocumentSnapshot, email: String) {
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
    var approvedAt:Date? = nil
    if let approvedAtInt = dictionary["approvedAt"] as? Int {
      approvedAt = NSDate.init(timeIntervalSince1970: TimeInterval(approvedAtInt) ) as Date
    }
    let requesterUserId = dictionary["userId"] as? String ?? ""
    var userRequestedAt: Date? = nil
    if let userRequestedAtInt = dictionary["userRequestedAt"] as? Int {
      
      userRequestedAt = NSDate.init(timeIntervalSince1970: TimeInterval(userRequestedAtInt)) as Date
    }
    let key = documentSnapshot.documentID

    self.init(amount: amount, currency: currency, paid: paid, date: date, recipient: recipient, id: id, customer: customer, refunded: refunded, approvedAt: approvedAt, requesterUserId: requesterUserId, userRequestedAt: userRequestedAt, email: email, key: key)
  }
}
