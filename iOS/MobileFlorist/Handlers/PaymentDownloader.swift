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
    db.collection("stripe_customers").document(uid).collection("charges").whereField("paid", isEqualTo: true).order(by: "date", descending: true)
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
        completion(charges, nil)
    }
  }
  
  func makePayment(source: String?, charge: Int, recipient: String?, completion: @escaping (Error?)->Void) {
    guard let uid = Auth.auth().currentUser?.uid else {
      let error = NSError(domain:"", code:5, userInfo:nil)
      completion(error)
      return
    }
    var data: [String: AnyObject] = ["amount": charge as AnyObject, "date": Date() as AnyObject]
    
    // Add source if chosen. Otherwise, charge will go to default source
    if let source = source {
      data["source"] = source as AnyObject
    }
    
    // Add recipient name if one was specified
    if let recipient = recipient {
      data["recipient"] = recipient as AnyObject
    }
    db.collection("stripe_customers").document(uid).collection("charges").addDocument(data: data) { error in
      if let error = error {
        completion(error)
        return
      } else {
        completion(nil)
      }
    }
  }
  
  func requestRefund(charge: Charge, amount: Int?, userId: String, completion: @escaping (Error?)->Void) {
    let amount = amount ?? charge.amount
    let id = charge.id
    let customer = charge.customer
    let requestTime = Date().timeIntervalSince1970*1000000
    print("request time: \(requestTime)")
    let requestDetails = "manually requested"
    let data = [
      Keys.AMOUNT.rawValue: amount as AnyObject,
      Keys.ID.rawValue: id as AnyObject,
      Keys.CUSTOMER.rawValue: customer as AnyObject,
      "userRequestedAt": requestTime as AnyObject,
      "userId": userId as AnyObject,
      "request_details": requestDetails as AnyObject
    ]
    db.collection("refund_requests").addDocument(data: data) { (error) in
      if let error = error {
        print(error)
        completion(error)
        return
      }
      completion(nil)
    }
  }
  
  func downloadRefunds(completion: @escaping ([RefundRequest], Error?) ->Void) {
    
    db.collection("refund_requests").addSnapshotListener(){ (snapshot, error) in
      var refunds = [RefundRequest]()
      var email = ""
      var userIdAndEmail = [String: String]()
      guard let documents = snapshot?.documents else {
        completion(refunds, error)
        return
      }
      let taskGroup = DispatchGroup()
      for document in documents {
        taskGroup.enter()
        let data = document.data()
        let uid = data["userId"] as? String
        if userIdAndEmail[uid!] == nil {
          Functions.functions().httpsCallable("getUser").call(["userId": uid]) { (result, error) in
            if error != nil { return }
            if let text = (result?.data as? [String: Any])?["email"] as? String {
              email = text
              userIdAndEmail[uid!] = email
            }
            let request = RefundRequest(documentSnapshot: document, email: email)
            if request.approvedAt == nil {
              refunds.append(request)
            }
            defer {
              taskGroup.leave()
            }
          }
        } else {
          let email = userIdAndEmail[uid!]
          let request = RefundRequest(documentSnapshot: document, email: email ?? "")
          defer {
            taskGroup.leave()
          }
        }
      taskGroup.notify(queue: DispatchQueue.main, execute: {
        completion(refunds, nil)
      })
    }
    }
  }
  
  func approveRefund(refundRequest: RefundRequest) {
  
   let date = Date()
    db.collection("refund_requests").document(refundRequest.key!).setData(["approvedAt": date], merge: true)
  }
}
