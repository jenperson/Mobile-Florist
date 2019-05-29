//
//  Source.swift
//  GoatLandscaping
//
//  Created by Jen Person on 8/15/18.
//  Copyright © 2018 Jen Person. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class Source {
  
  var token: String = ""
  var address_city: String?
  var address_country: String?
  var address_line1: String?
  var address_line1_check: String?
  var address_line2: String?
  var address_state: String?
  var address_zip: String?
  var address_zip_check: String?
  var brand: String?
  var country: String?
  var customer: String?
  var error: String?
  var exp_month: Int = 1
  var exp_year: Int = 2020
  var fingerprint: String = ""
  var id: String?
  var last4: String?
  var name: String?
  
  fileprivate enum Keys: String {
    case ADDRESS_CITY = "address_city"
    case ADDRESS_COUNTRY = "address_country"
    case ADDRESS_LINE1 = "address_line1"
    case ADDRESS_LINE2 = "address_line2"
    case ADDRESS_STATE = "address_state"
    case ADDRESS_ZIP = "address_zip"
    case BRAND = "brand"
    case COUNTRY = "country"
    case CUSTOMER = "customer"
    case TOKEN = "token"
    case ERROR = "error"
    case EXP_MONTH = "exp_month"
    case EXP_YEAR = "exp_year"
    case FINGERPRINT = "fingerprint"
    case ID = "id"
    case LAST4 = "last4"
    case NAME = "name"
  }
  
  init(token: String, address_city: String? = nil, address_country: String? = nil, address_line1: String? = nil, address_line2: String? = nil, address_state: String? = nil, address_zip: String? = nil,
       brand: String? = nil, country: String? = nil, customer: String? = nil, error: String? = nil, exp_month: Int, exp_year: Int, fingerprint: String, id: String? = nil, last4: String? = nil, name: String? = nil) {
    self.token = token
    self.address_city = address_city
    self.address_country = address_country
    self.address_line1 = address_line1
    self.address_line2 = address_line2
    self.address_state = address_state
    self.address_zip = address_zip
    self.brand = brand
    self.country = country
    self.customer = customer
    self.error = error
    self.exp_month = exp_month
    self.exp_year = exp_year
    self.fingerprint = fingerprint
    self.id = id
    self.last4 = last4
    self.name = name
    
  }
  
  convenience init(documentSnapshot: QueryDocumentSnapshot) {
    let dictionary = documentSnapshot.data()
    let token = dictionary[Keys.TOKEN.rawValue] as? String ?? ""
    let customer = dictionary[Keys.CUSTOMER.rawValue] as? String ?? ""
    let address_city = dictionary[Keys.ADDRESS_CITY.rawValue] as? String ?? ""
    let address_country = dictionary[Keys.ADDRESS_COUNTRY.rawValue] as? String ?? ""
    let address_line1 = dictionary[Keys.ADDRESS_LINE1.rawValue] as? String
    let address_line2 = dictionary[Keys.ADDRESS_LINE2.rawValue] as? String ?? ""
    let address_state = dictionary[Keys.ADDRESS_STATE.rawValue] as? String ?? ""
    let address_zip = dictionary[Keys.ADDRESS_ZIP.rawValue] as? String ?? ""
    let brand = dictionary[Keys.BRAND.rawValue] as? String ?? ""
    let country = dictionary[Keys.COUNTRY.rawValue] as? String ?? ""
    let error = dictionary[Keys.ERROR.rawValue] as? String ?? ""
    let exp_month = dictionary[Keys.EXP_MONTH.rawValue] as? Int ?? 1
    let exp_year = dictionary[Keys.EXP_YEAR.rawValue] as? Int ?? 2020
    let fingerprint = dictionary[Keys.FINGERPRINT.rawValue] as? String ?? ""
    let id = dictionary[Keys.ID.rawValue] as? String ?? ""
    let last4 = dictionary[Keys.LAST4.rawValue] as? String ?? ""
    let name = dictionary[Keys.NAME.rawValue] as? String ?? ""
    self.init(token: token, address_city: address_city, address_country: address_country, address_line1: address_line1, address_line2: address_line2, address_state: address_state, address_zip: address_zip, brand: brand, country: country, customer: customer, error: error, exp_month: exp_month, exp_year: exp_year, fingerprint: fingerprint, id: id, last4: last4, name: name)
  }
}
