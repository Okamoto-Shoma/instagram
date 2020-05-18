//
//  PostViewController.swift
//  Instagram
//
//  Created by 岡本 翔真 on 2020/05/08.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PostViewController: UIViewController {
    
    var image: UIImage!
    
    //MARK: - IBOutlet
    
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var imageView: UIImageView!
    
    //MARK: - LifiCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //受け取った画像をImageViewに設定する
        self.imageView.image = self.image

        // Do any additional setup after loading the view.
    }
    
    //MARK: - IBAction
    
    /// 投稿ボタン押下時
    /// - Parameter sender: UIButton
    @IBAction func handlePostButton(_ sender: UIButton) {
        //画像をJPEG形式に変換する
        let imageData = self.image.jpegData(compressionQuality: 0.75)
        //画像と投稿データの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        //HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        //Storageに画像をアップロードする
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            if error != nil {
                //画像のアップロード失敗
                print(error!)
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                //投稿処理をキャンセルし、先頭画面に戻る
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                return
            }
            //FireStoreに投稿データを保存
            let name = Auth.auth().currentUser?.displayName
            let postDic = [
                "name": name!,
                "caption": self.textField.text!,
                "commentsName": "",
                "comments": "",
                "date": FieldValue.serverTimestamp(),
            ] as [String: Any]
            postRef.setData(postDic)
            //HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            //投稿処理が完了したので先頭画面に戻る
            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    /// キャンセルボタン押下時
    /// - Parameter sender: UIButton
    @IBAction func handleCancelButton(_ sender: UIButton) {
        
        //加工画面に戻る
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
