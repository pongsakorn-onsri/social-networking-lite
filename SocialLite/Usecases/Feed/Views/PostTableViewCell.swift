//
//  PostTableViewCell.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 6/4/2564 BE.
//

import UIKit
import RxSwift
import FirebaseFirestore

final class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

extension PostTableViewCell {
    func configure(with viewModel: PostCellViewModel) {
        let post = viewModel.post
        let dateFormatter = DateFormatter(withFormat: "MM-dd-yyyy HH:mm", locale: Locale.current.identifier)
        let dateString = dateFormatter.string(from: post.timestamp.dateValue())
        titleLabel.text = post.displayName
        timeLabel.text = dateString
        descriptionLabel.text = post.content
        deleteButton.isHidden = post.userId != UserManager.shared.currentUser?.uid
    }
}
