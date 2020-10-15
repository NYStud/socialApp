//
//  Validators.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class Validators {
    
    static let shared = Validators()
    
    private init() {}
    
    func isFilledRegister(email: String?, password: String?, confirmPassword: String? ) -> (isFilled: Bool,
                                                                                    email: String,
                                                                                    password: String,
                                                                                    confirmPassword: String) {
        guard let email = email,
            let password = password,
            let confirmPassword = confirmPassword,
            email != "",
            password != "",
            confirmPassword != ""
            else { return (false, "", "", "") }
        
        return (true, email, password, confirmPassword)
    }
    
    func isFilledSignIn(email: String?, password: String?) -> (isFilled: Bool,
                                                                email: String,
                                                                password: String) {
        guard let email = email,
              let password = password,
              email != "",
              password != ""
              else { return (false, "", "") }
        
        return (true, email, password)
    }
    
    
    func isFilledUserName(userName: String? ) -> (isFilled: Bool,
                                                  userName: String) {
        guard let userName = userName,
              userName != ""
              else { return (false, "") }
        
        return (true, userName)
    }
    
    func isSetProfileImage(image: UIImage) -> Bool {
        return true
    }
    
    
    func isEmail(email: String) -> Bool {
        
        let mailRegEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        return checkRegEx(text: email, regEx: mailRegEX)
    }
    
     func isConfirmPassword(password1: String, password2: String) -> Bool {
 
        return password1 == password2
    }
    
    private func checkRegEx(text: String, regEx: String) -> Bool {
        let textCheck  = NSPredicate(format:"SELF MATCHES %@", regEx)
        return textCheck.evaluate(with: text)
    }
    
    
    
}
