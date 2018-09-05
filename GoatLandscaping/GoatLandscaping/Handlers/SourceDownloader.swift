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
  
  // MARK: Properties
  
  lazy var db = Firestore.firestore()

  init() {

  }

  // Download a list of credit cards and other payment sources
  func downloadSources(completion: @escaping ([Source], Error?)->Void) {
    var sources = [Source]()
    guard let uid = Auth.auth().currentUser?.uid else {
      let error = NSError(domain:"", code:5, userInfo:nil)
      completion(sources, error)
      return
    }
    db.collection("stripe_customers").document(uid).collection("sources")
    .addSnapshotListener(includeMetadataChanges: true) { (querySnapshot, err) in
      sources = []
      guard let documents = querySnapshot?.documents else {
        print("Error fetching documents: \(err!)")
        completion(sources, err)
        return
      }
      for document in documents {
        let source = Source(documentSnapshot: document)
        print(source)
        print(source.token)
        sources.append(source)
      }
      print(sources)
      completion(sources, nil)
    }
  }
  
  func writeCardTokenToDB(token: String, completion: @escaping (String?) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    db.collection("stripe_customers").document(uid).collection("tokens").addDocument(data: ["token": token]) { err in
      if let err = err {
        print(err)
        completion(err.localizedDescription)
      } else {
        completion(nil)
      }
    }
  }
  
  
}
