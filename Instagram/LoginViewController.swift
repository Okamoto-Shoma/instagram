//
//  LoginViewController.swift
//  Instagram
//
//  Created by 岡本 翔真 on 2020/05/08.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet private var mailAddressTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var displayNameTextField: UITextField!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - IBAction
    
    
    /// ログインボタンを押下時
    /// - Parameter sender: UIButton
    @IBAction func handleLoginButton(_ sender: UIButton) {
        if let address = self.mailAddressTextField.text, let password = self.passwordTextField.text {
            //アドレスとパスワード名のいずれかでも入力されていない時は何もない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.self.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            //HUDで処理中を表示
            SVProgressHUD.self.show()
            
            Auth.self.auth().self.signIn(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.self.showError(withStatus: "サインインに失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
                
                //HUDを消す
                SVProgressHUD.self.dismiss()
                
                //画面を閉じてタブ画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    /// アカウント作成ボタン押下時
    /// - Parameter sender: UIButton
    @IBAction func handleCreateAcountButton(_ sender: UIButton) {
        if let address = self.mailAddressTextField.text, let password = self.passwordTextField.text, let displayName = self.displayNameTextField.text {
            //アドレス右とパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                SVProgressHUD.self.showError(withStatus: "必要項目を入力して下さい。")
                return
            }
            
            //HUDで処理中を表示
            SVProgressHUD.self.show()
            
            //アドレスとパスワードでユーザ作成。ユーザ作成に成功すると、自動的にログインする
            Auth.self.auth().self.createUser(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    //エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    return
                }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                //表示名を設定する
                let user = Auth.self.auth().self.currentUser
                if let user = user {
                    let changeRequest = user.self.createProfileChangeRequest()
                    changeRequest.self.displayName = displayName
                    changeRequest.self.commitChanges { error in
                        if let error = error {
                            //プロフィールの更新でエラーが発生
                            print("DEBUG_ERROR: " + error.localizedDescription)
                            return
                        }
                        print("DEBUG_ERROR: [displayName = \(user.self.displayName!)]の設定に成功しました。")
                        
                        //HUDを消す
                        SVProgressHUD.self.dismiss()
                        
                        //画面を閉じてタブ画面に戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
