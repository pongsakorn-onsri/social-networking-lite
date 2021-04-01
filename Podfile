platform :ios, '13.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'SocialLite' do
  use_frameworks!

  # UI
  pod 'MaterialComponents'
  pod 'EmptyDataSet-Swift', '~> 5.0.0'
  
  # Linter
  pod 'SwiftLint'
  
  # Parser
  pod 'ObjectMapper'
  
  # Base
  pod 'Firebase'
  pod 'XCoordinator/RxSwift', '~> 2.0.3'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'RxDataSources', '~> 4.0'

  target 'SocialLiteTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end

  target 'SocialLiteUITests' do
    # Pods for testing
  end

end
