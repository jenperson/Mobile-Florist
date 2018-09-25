//
//  SourceViewController.swift
//  GoatLandscaping
//
//  Created by Jen Person on 8/13/18.
//  Copyright © 2018 Jen Person. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import Stripe

class SourceViewController: UIViewController {

  // MARK: Properties
  
  lazy var sourceDownloader = SourceDownloader()
  lazy var authHandler = AuthHandler()
  var isUser = false
  var sources = [Source]()
  let sourceCell = "source_cell"
  var user: User?
  
  // MARK: Outlets
  
  @IBOutlet weak var sourceTableView: UITableView!
  @IBOutlet weak var moreButton: UIBarButtonItem!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    authHandler.checkLoginStatus { currUser in
      self.user = currUser
      if let _ = currUser  {
        self.sourceDownloader.downloadSources(completion: { (sources, err) in
          self.sources = sources
          self.sourceTableView.reloadData()
          if let err = err {
            print(err)
          }
        })
      }
    }
    
  }

  func displayActionSheet(isUser: Bool) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    if let _ = user {
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

extension SourceViewController: STPAddCardViewControllerDelegate {
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
    print(token)
    sourceDownloader.writeCardTokenToDB(token: token.tokenId) { err in
      self.dismiss(animated: true)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
        
      })
      let alertController = UIAlertController(title: "Success!", message: "card added", preferredStyle: .alert)
      alertController.addAction(okAction)
      if let err = err {
        alertController.title = "Error"
        alertController.message = err
      }
      self.navigationController?.present(alertController, animated: true, completion:nil)
    }
    
  }
}

extension SourceViewController: UITableViewDelegate, UITableViewDataSource {
 
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sources.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: sourceCell, for: indexPath) as! SourceTableViewCell
    cell.source = sources[indexPath.item]
    return cell
    
  }
  
}
