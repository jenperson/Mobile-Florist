//
//  SourceDownloader.swift
//  GoatLandscaping
//
//  Created by Jen Person on 8/13/18.
//  Copyright © 2018 Jen Person. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import Stripe

class SourceDownloader {
  
  lazy var db = Firestore.firestore()
  //user: User?
  init() {

  }
  
  func downloadSources() {
    let cardParams = STPCardParams()
    cardParams.number = "4242424242424242"
    cardParams.expMonth = 10
    cardParams.expYear = 2018
    cardParams.cvc = "123"
    
    STPAPIClient.shared().createToken(withCard: cardParams) { (token: STPToken?, error: Error?) in
      guard let token = token, error == nil else {
        // Present error to user...
        return
      }
//
//      submitTokenToBackend(token, completion: { (error: Error?) in
//        if let error = error {
//          // Present error to user...
//        }
//        else {
//          // Continue with payment...
//        }
//      })
      print(token.stripeID)
      self.writeCardTokenToDB(token: token.tokenId) {  err in
        if let err = err {
          print(err)
        }
      }
    }

  }
  
  func writeCardTokenToDB(token: String, completion: @escaping (String?) -> Void) {
    print(Auth.auth().currentUser?.uid)
    db.collection("stripe_customers").document((Auth.auth().currentUser?.uid)!).collection("sources").addDocument(data: ["token": token]) { err in
      if let err = err {
        print(err)
        completion(err.localizedDescription)
      } else {
        completion(nil)
      }
    }
  }
}
