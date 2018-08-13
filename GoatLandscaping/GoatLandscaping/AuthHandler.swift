//
//  AuthHandler.swift
//  GoatLandscaping
//
//  Created by Jen Person on 8/13/18.
//  Copyright © 2018 Jen Person. All rights reserved.
//

import Foundation
import Firebase
import FirebaseUI

var isUser = false


class AuthHandler: NSObject, FUIAuthDelegate {
  
  var authUI: FUIAuth?
  var user: User?
  
  override init() {
    authUI = FUIAuth.defaultAuthUI()
    let providers: [FUIAuthProvider] = [
      FUIGoogleAuth(),
      ]
    self.authUI?.providers = providers
  }
  
  func checkLoginStatus(completion: @escaping (Bool) -> Void) {
    Auth.auth().addStateDidChangeListener { auth, user in
      if let currUser = auth.currentUser {
//        if currUser.isAnonymous {
//          completion(false)
//          return
//        }
        self.user = currUser
        completion(true)
      } else {
        //self.signIn()
        completion(false)
        //Auth.auth().signInAnonymously(completion: nil)
      }
    }
//
//    Auth.auth().createUser(withEmail: "test@test.com", password: "test") { (authresult, err) in
//      guard let authresult = authresult else { return }
//      let user = authresult.user
//    }
  }
  
  
  func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
    // handle user and error as necessary
  }
  
  func signIn() {
    let authViewController = self.authUI!.authViewController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.window?.rootViewController?.present(authViewController, animated: true, completion: nil)
  }
  
  func signOut() {
    do {
      try self.authUI!.signOut()
    } catch {
      print("unable to logout")
    }
  }
}

