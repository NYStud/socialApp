//
//  SignUpViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 28.06.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI

class SignUpViewController: UIViewController {
    
    
    let signUpLogo = UIImageView(image: #imageLiteral(resourceName: "SignUpLogo"),
                                 contentMode: .scaleAspectFit)
    
    let loginLabel = UILabel(labelText: "Email")
    let passwordLabel = UILabel(labelText: "Пароль")
    let confirmPasswordLabel = UILabel(labelText: "Повтори пароль")
    let onboardLabel = UILabel(labelText: "Уже с нами?")
    
    let loginTextField = OneLineTextField(isSecureText: false)
    let passwordTextField = OneLineTextField(isSecureText: true)
    let confirmPasswordTextField = OneLineTextField(isSecureText: true)
    
    let signUpButton = UIButton(newBackgroundColor: .label,
                                newBorderColor: .label,
                                title: "Зарегистрироваться",
                                titleColor: .systemBackground)
    
    let loginButton = UIButton(newBackgroundColor: .systemBackground,
                               newBorderColor: .label,
                               title: "Вход",
                               titleColor: .label)
    
    weak var delegate: AuthNavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVC()
        setupConstraints()
        setupButtonAction()
    }    
}

//MARK: - setupVC
extension SignUpViewController {
    
    private func setupVC() {
        view.backgroundColor = .systemBackground
        
    }
}

//MARK: - setupButtonAction
extension SignUpViewController {
    
    private func setupButtonAction() {
        
        signUpButton.addTarget(self, action: #selector(signUpButtonPressed), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
    }
}

//MARK: - objc action
extension SignUpViewController {
    
    @objc func signUpButtonPressed() {
        
        signUpButton.isEnabled = false
        AuthService.shared.register(email: loginTextField.text,
                                    password: passwordTextField.text,
                                    confirmPassword: confirmPasswordTextField.text) {[weak self] result in
                                        
                                        switch result {
                                            
                                        case .success(let user):
                                            print("Uspeh")
                                            if let userName = user.email {
                                                
                                                self?.showAlert(title: "Создан",
                                                                text: userName,
                                                                buttonText: "Начнем",
                                                                complition: {
                                                                    self?.dismiss(animated: true,
                                                                                  completion: {
                                                                                    self?.delegate?.toMainTabBar()
                                                                    })
                                                                    
                                                })
                                            }
                                            
                                        case .failure(let error):
                                            let myError = error.localizedDescription
                                            self?.showAlert(title: "Ошибка",
                                                            text: myError,
                                                            buttonText: "Понятно")
                                            self?.signUpButton.isEnabled = true
                                            
                                        }
        }
        
    }
    
    @objc func loginButtonPressed() {
        dismiss(animated: true) {
            self.delegate?.toLogin()
        }
    }
}

//MARK: - setupConstraints
extension SignUpViewController {
    private func setupConstraints() {
        
        signUpLogo.translatesAutoresizingMaskIntoConstraints = false
        loginTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        onboardLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(signUpLogo)
        view.addSubview(loginTextField)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(loginLabel)
        view.addSubview(passwordLabel)
        view.addSubview(confirmPasswordLabel)
        view.addSubview(signUpButton)
        view.addSubview(loginButton)
        view.addSubview(onboardLabel)
        
        NSLayoutConstraint.activate([
            signUpLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            signUpLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loginTextField.topAnchor.constraint(equalTo: signUpLogo.bottomAnchor, constant: 28),
            loginTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            loginTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            loginLabel.bottomAnchor.constraint(equalTo: loginTextField.topAnchor, constant: -5),
            loginLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            loginLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 68),
            passwordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            passwordLabel.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -5),
            passwordLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            passwordLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 68),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            confirmPasswordLabel.bottomAnchor.constraint(equalTo: confirmPasswordTextField.topAnchor, constant: -5),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            confirmPasswordLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            signUpButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 25),
            signUpButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            signUpButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            signUpButton.heightAnchor.constraint(equalTo: signUpButton.widthAnchor, multiplier: 1.0/7.28),
            
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            loginButton.heightAnchor.constraint(equalTo: loginButton.widthAnchor, multiplier: 1.0/7.28),
            
            onboardLabel.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -10),
            onboardLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

//MARK: - showAlert
extension SignUpViewController {
    
    private func showAlert(title: String,
                           text: String,
                           buttonText: String,
                           complition: @escaping ()-> Void = { }) {
        
        let alert = UIAlertController(title: title,
                                      text: text,
                                      buttonText: buttonText,
                                      style: .alert,
                                      buttonHandler: complition)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - SwiftUI
struct SignUpViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContenerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContenerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> SignUpViewController {
            SignUpViewController()
        }
        
        func updateUIViewController(_ uiViewController: SignUpViewController, context: Context) {
            
        }
    }
}
