//
//  LoginViewController.swift
//  OMGShop
//
//  Created by Mederic Petit on 19/10/2560 BE.
//  Copyright © 2560 Mederic Petit. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {

    let viewModel: BaseViewModel = LoginViewModel()

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController {

    @IBAction func tapLoginButton(_ sender: UIButton) {

    }

}
