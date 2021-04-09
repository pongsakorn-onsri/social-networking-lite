//
//  CreatePostViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 3/4/2564 BE.
//

import UIKit
import RxSwift
import MaterialComponents
import RxCocoa

extension CreatePostViewController: UseStoryboard {
    static var storyboardName: String { "CreatePost" }
}

class CreatePostViewController: UIViewController, UseViewModel {

    // MARK: - IBOutlets
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var textArea: MDCOutlinedTextArea!
    
    // MARK: - Properties
    typealias Model = CreatePostViewModel
    var viewModel: Model?
    var disposeBag = DisposeBag()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        bindViewModel()
        textArea.textView.becomeFirstResponder()
    }
    
    func configureViews() {
        textArea.placeholder = "Input your text here."
        textArea.sizeToFit()
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        let input = CreatePostViewModel.Input(
            textInput: textArea.textView.rx.text.orEmpty.asDriver(),
            closeTapped: closeButton.rx.tap.asDriver(),
            createTapped: createButton.rx.tap.asDriver()
        )
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        output.$countingText
            .bind(to: textArea.trailingAssistiveLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.$isLoading
            .asDriver()
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        output.$isLoading
            .asDriver()
            .drive(isLoadingBinder)
            .disposed(by: disposeBag)
        
        output.$validateMessage
            .asDriver()
            .drive(validationMessageBinder)
            .disposed(by: disposeBag)
    }
    
    func applyTheme(with containerScheme: MDCContainerScheming) {
        textArea.applyTheme(withScheme: containerScheme)
    }
}

// MARK: - Binders
extension CreatePostViewController {
    var isLoadingBinder: Binder<Bool> {
        return Binder(createButton) { button, isLoading in
            button.title = isLoading ? "" : "CREATE"
        }
    }
    
    var validationMessageBinder: Binder<String> {
        return Binder(textArea) { textArea, message in
            textArea.leadingAssistiveLabel.text = message
            if message.isEmpty {
                textArea.applyTheme(withScheme: containerScheme)
            } else {
                textArea.applyErrorTheme(withScheme: containerScheme)
            }
        }
    }
}
