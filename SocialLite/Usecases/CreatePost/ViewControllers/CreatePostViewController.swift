//
//  CreatePostViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 3/4/2564 BE.
//

import UIKit
import RxSwift
import MaterialComponents

extension CreatePostViewController: UseStoryboard {
    static var storyboardName: String { "CreatePost" }
}

class CreatePostViewController: BaseViewController<CreatePostViewModel> {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var textArea: MDCOutlinedTextArea!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureBinding()
        textArea.textView.becomeFirstResponder()
    }
    
    func configureViews() {
        textArea.placeholder = "Input your text here."
        textArea.sizeToFit()
    }
    
    func configureBinding() {
        guard let viewModel = viewModel else { return }
        let input = CreatePostViewModel.Input(
            closeTapped: closeButton.rx.tap.asObservable(),
            createTapped: createButton.rx.tap.asObservable(),
            textInput: textArea.textView.rx.text.orEmpty.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        output.countingText
            .bind(to: textArea.trailingAssistiveLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.isPosting
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        output.validate
            .drive(onNext: { [weak self]error in
                if let error = error {
                    self?.textArea.applyErrorTheme(withScheme: containerScheme)
                    self?.textArea.leadingAssistiveLabel.text = error.localizedDescription
                } else {
                    self?.textArea.applyTheme(withScheme: containerScheme)
                    self?.textArea.leadingAssistiveLabel.text = nil
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func applyTheme(with containerScheme: MDCContainerScheming) {
        textArea.applyTheme(withScheme: containerScheme)
    }
}


