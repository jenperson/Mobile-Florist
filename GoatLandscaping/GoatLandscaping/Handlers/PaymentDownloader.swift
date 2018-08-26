//
//  PaymentDownloader.swift
//  GoatLandscaping
//
//  Created by Jen Person on 8/20/18.
//  Copyright © 2018 Jen Person. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class PaymentDownloader {
  
  // MARK: Properties
  
  lazy var db = Firestore.firestore()
  
  init() {
    
  }
  
  func downloadPayments(completion: @escaping ([Charge], Error?)->Void) {
    var charges = [Charge]()
    guard let uid = Auth.auth().currentUser?.uid else {
      let error = NSError(domain:"", code:5, userInfo:nil)
      completion(charges, error)
      return
    }
    db.collection("stripe_customers").document(uid).collection("charges")
      .addSnapshotListener(includeMetadataChanges: true)
      { (querySnapshot, err) in
        charges = []
        guard let documents = querySnapshot?.documents else {
          print("Error fetching documents: \(err!)")
          completion(charges, err)
          return
        }
        for document in documents {
          let charge = Charge(documentSnapshot: document)
          charges.append(charge)
        }
        print(charges)
        completion(charges, nil)
    }
  }
  //    firebase.firestore().collection('stripe_customers').doc(this.currentUser.uid).collection('charges').add({
  //      source: this.newCharge.source,
  //      amount: parseInt(this.newCharge.amount)

func makePayment(source: String, charge: Int, completion: @escaping (Error?)->Void) {
    guard let uid = Auth.auth().currentUser?.uid else {
      let error = NSError(domain:"", code:5, userInfo:nil)
      completion(error)
      return
    }
  db.collection("stripe_customers").document(uid).collection("charges").addDocument(data: [
    "source": source,
    "amount": charge
  ]) { error in
    if let error = error {
      completion(error)
      return
    } else {
      completion(nil)
    }
    }
  }
}
