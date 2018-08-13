//
//  ViewController.swift
//  GoatLandscaping
//
//  Created by Jen Person on 8/13/18.
//  Copyright © 2018 Jen Person. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import Stripe

class ViewController: UIViewController {

  // MARK: Properties
  
  lazy var sourceDownloader = SourceDownloader()
  lazy var authHandler = AuthHandler()
  var isUser = false
  
  // MARK: Outlets
  
  @IBOutlet weak var moreButton: UIBarButtonItem!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view, typically from a nib.
    authHandler.checkLoginStatus { (isUser) in
      if isUser == true {
        self.isUser = isUser
       // self.sourceDownloader.downloadSources()
      }
    }
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func displayActionSheet(isUser: Bool) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    if isUser == true {
      let logoutAction = UIAlertAction(title: "Log Out", style: .default) { action in
        self.authHandler.signOut()
      }
      let addPaymentAction = UIAlertAction(title: "Add Credit card", style: .default) { action in
        self.handleAddPaymentMethodButtonTapped()
      }
      alertController.addAction(logoutAction)
      alertController.addAction(addPaymentAction)
    } else {
      let loginAction = UIAlertAction(title: "Log In", style: .default) { action in
        self.authHandler.signIn()
      }
      alertController.addAction(loginAction)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    self.navigationController?.present(alertController, animated: true, completion: nil)
  }


  @IBAction func didTapMoreButton(_ sender: Any) {
    displayActionSheet(isUser: isUser)
  }
}

extension ViewController: STPAddCardViewControllerDelegate {
  func handleAddPaymentMethodButtonTapped() {
    // Setup add card view controller
    let addCardViewController = STPAddCardViewController()
    addCardViewController.delegate = self
    
    // Present add card view controller
    let navigationController = UINavigationController(rootViewController: addCardViewController)
    present(navigationController, animated: true)
  }
  
  // MARK: STPAddCardViewControllerDelegate
  
  func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
    // Dismiss add card view controller
    dismiss(animated: true)
  }
  
  func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
    sourceDownloader.writeCardTokenToDB(token: token.tokenId) { err in
      self.dismiss(animated: true)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
        
      })
      var alertController = UIAlertController(title: "Success!", message: "card added", preferredStyle: .alert)
      alertController.addAction(okAction)
      if let err = err {
        alertController.title = "Error"
        alertController.message = err
      }
      self.navigationController?.present(alertController, animated: true, completion:nil)
    }
    
  }
}
