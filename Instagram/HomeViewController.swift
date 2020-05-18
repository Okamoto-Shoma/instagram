//
//  HomeViewController.swift
//  Instagram
//
//  Created by 岡本 翔真 on 2020/05/08.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //投稿データを格納する配列
    var postArray: [PostData] = []
    //Firestoreのリスナー
    var listener: ListenerRegistration!
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //カスタムセルを登録
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillApeear")
        
        if Auth.auth().currentUser != nil {
            //ログイン済
            if self.listener == nil {
                //listener未登録なら、登録してスナップショットを受信する
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                self.listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: sunapshotの取得が失敗しました。\(error)")
                        return
                    }
                    //取得したdocumentをもとにPostDataを作成し、postArrayの配列にする
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得\(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    //TableViewの表示を更新
                    self.tableView.reloadData()
                }
            }
        } else {
            //ログイン未(またはログアウト済)
            if self.listener != nil {
                //listener登録済なら削除してpostArrayをクリア
                self.listener.remove()
                self.listener = nil
                self.postArray = []
                self.tableView.reloadData()
            }
        }
    }

    
    //MARK: - Action
    
    //いいねボタン押下時処理
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[indexPath!.row]
        
        //likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            //更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                //すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                //今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            //likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    //コメントボタン押下時処理
    @objc func commentButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: commentボタンがタップされました")
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[indexPath!.row]
                
        //遷移処理
        let storyboard: UIStoryboard = self.storyboard!
        let commentController = storyboard.instantiateViewController(withIdentifier: "Segue") as? CommentViewController
        commentController?.self.postDataReceived = postData
        self.present(commentController!, animated: true, completion: nil)
    }
    
    //MARK: - Method
    
    /// tableViewの行数
    /// - Parameter tableView: UITableView
    /// - Parameter section: Int
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postArray.count
    }
    
    /// セル内情報処理
    /// - Parameter tableView: UITableView
    /// - Parameter indexPath: IndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.self.setPostData(self.postArray[indexPath.row])
        
        //いいねボタンのアクションをソースコードで設定する
        cell.self.likeButton.addTarget(self, action:#selector(self.handleButton(_:forEvent:)), for: .touchUpInside)
        
        //コメントボタンのアクションをソースコードで設定
        cell.self.commentButton.addTarget(self, action: #selector(self.commentButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
}
