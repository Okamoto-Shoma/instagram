//
//  CommentViewController.swift
//  Instagram
//
//  Created by 岡本 翔真 on 2020/05/13.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CommentViewController: UIViewController {
    
    var commentArray: [String] = []
    //前画面からデータを受け取るための変数
    var postDataReceived: PostData?
    
    //MARK: - Outlet
    
    @IBOutlet private var commentTextField: UITextField!
    @IBOutlet weak var commentTableView: UITableView!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentTableView.delegate = self
        self.commentTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.commentArray = postDataReceived!.comments
    }
    
    //MARK: - Action
    
    
    /// コメント投稿処理
    /// - Parameter sender: UIButton
    @IBAction func commentHandleButton(_ sender: UIButton) {
        guard let inputCommentField = commentTextField.text, !inputCommentField.isEmpty else {
            SVProgressHUD.showError(withStatus: "コメントが入力されていません")
            return
        }
        
        guard let postData = postDataReceived else { return }
        postData.comments.append("comments")
        
        var updateValue: FieldValue
        let commentRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
        //FireStoreに投稿データを保存
        let name = Auth.auth().currentUser?.displayName
        let comment = name! + "：" + self.commentTextField.text!
        
        updateValue = FieldValue.arrayUnion([comment])
        commentRef.updateData(["comments": updateValue])
        
        print("DEBUG_UPDATEVALUE: \(updateValue)")
        
        //HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        
        //投稿処理が完了したので先頭画面に戻る
        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    //MARK: - Method
    
}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ commentTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.commentArray.count
    }
    
    func tableView(_ commentTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得してデータを設定する
        let cell = self.commentTableView.dequeueReusableCell(withIdentifier: "Cells", for: indexPath)
        
        //セルに設定
        cell.textLabel?.text = commentArray[indexPath.row]
        
        return cell
    }
}
