//
//  CreatePostViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 3/4/2564 BE.
//

import UIKit
import RxSwift

extension CreatePostViewController: UseStoryboard {
    static var storyboardName: String { "CreatePost" }
}

class CreatePostViewController: BaseViewController<CreatePostViewModel> {

    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBinding()
    }
    
    func configureBinding() {
        guard let viewModel = viewModel else { return }
        let input = CreatePostViewModel.Input(closeTapped: closeButton.rx.tap.asObservable())
        
        _ = viewModel.transform(input: input)
    }
}


