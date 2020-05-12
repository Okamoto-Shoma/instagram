//
//  SettingViewController.swift
//  Instagram
//
//  Created by 岡本 翔真 on 2020/05/08.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SettingViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet private var displayNameTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //表示名を取得してTextFieldに設定する
        let user = Auth.self.auth().self.currentUser
        if let user = user {
            self.displayNameTextField.text = user.self.displayName
        }
    }
    
    //MARK: - IBAction
    
    
    /// 表示名変更押下時
    /// - Parameter sender: UIButton
    @IBAction func handleChangeButton(_ sender: UIButton) {
        
        if let disPlayName = self.displayNameTextField.text {
            
            //表示名が乳yろくされていないときはHUDを出して何もしない
            if disPlayName.isEmpty {
                SVProgressHUD.self.showError(withStatus: "表示名を入力して下さい")
                return
            }
            
            //表示名を設定する
            let user = Auth.self.auth().self.currentUser
            if let user = user {
                let changeRequset = user.self.createProfileChangeRequest()
                changeRequset.self.displayName = disPlayName
                changeRequset.self.commitChanges{ error in
                    if let error = error {
                        SVProgressHUD.self.showError(withStatus: "表示名の変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT: [displayName = \(user.self.displayName!)の設定に成功しました。")
                    
                    //HUDで完了を知らせる
                    SVProgressHUD.self.showSuccess(withStatus: "表示名を変更しました")
                }
            }
        }
        //キーボードを閉じる
        self.view.endEditing(true)
    }
    
    /// ログアウト押下時
    /// - Parameter sender: UIButton
    @IBAction func handleLogoutButton(_ sender: UIButton) {
        
        //ログアウトする
        try? Auth.self.auth().self.signOut()
        
        //ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)
        
        //ログイン画面から戻ってきたときのためにホーム画面(index = 0)を選択している状態にしておく
        tabBarController?.selectedIndex = 0
    }
    
    
}
