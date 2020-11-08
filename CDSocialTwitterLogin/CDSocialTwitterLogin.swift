//
//  CDSocialTwitterLogin.swift
//  CDSocialTwitterLogin
//
//  Created by Apple on 08/11/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit

public protocol CDSocialTwitterLoginDelegate: class {
    func didSignInTwitter()
    func didSignOutTwitter()
}

public class CDSocialTwitterLogin: NSObject {

    public static let shared = CDSocialTwitterLogin()
    public  weak var delegate: CDSocialTwitterLoginDelegate?
    var twitterProvider : OAuthProvider?


    private override init(){}

    public func settwitterInitialSetUp() {
        self.twitterProvider = OAuthProvider(providerID:"twitter.com")
    }

}

extension CDSocialTwitterLogin {
    public func getTwitterDataDict() -> Dictionary<String,AnyObject>? {
        if let dict = UserDefaults.standard.object(forKey: "TwitterUser") as? [String : AnyObject]  {
            return dict
        }
        return nil
    }

   public func signInToTwitter() {
        twitterProvider!.getCredentialWith(nil) { [weak self] credential, error in
            if let error = error {
                print("error")
                return
            }

            if let credential = credential {
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        print("error")
                        return

                    }
                    if let userID = authResult?.user.uid {
                        let userName = authResult?.user.displayName
                        let userId = authResult?.user.uid
                        var dict = Dictionary<String,Any>()
                        dict["UId"] = userId
                        dict["name"] = userName
                        UserDefaults.standard.set(dict, forKey: "TwitterUser")
                        print(userID)
                        self?.getTwitterData()
                        return

                    }
                }
            }
        }
    }

    public func getTwitterData() {
        self.delegate?.didSignInTwitter()
    }

    public func logoutFromTwitter() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
        print ("Error signing out: %@", signOutError)
    }
    UserDefaults.standard.removeObject(forKey: "TwitterUser")
    self.delegate?.didSignOutTwitter()
  }
}
