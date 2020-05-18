//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 岡本 翔真 on 2020/05/12.
//  Copyright © 2020 shoma.okamoto. All rights reserved.
//

import UIKit
import FirebaseUI

class PostTableViewCell: UITableViewCell {
    
    //MARK: - Outlet
    
    @IBOutlet private var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet private var likeLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var captionLabel: UILabel!
    @IBOutlet private var commentLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    //MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Method
    
    func setPostData(_ postData: PostData) {
        //画像表示
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)
        
        //キャプションの表示
        self.captionLabel.text = "\(postData.name!)：\(postData.caption!)"
        
        //コメントの表示
        let comments = postData.comments.joined(separator: "\n")
        self.commentLabel.text = comments
        
        //日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }
        
        //いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "いいね：\(likeNumber)"
        
        //いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
    }
    
}
