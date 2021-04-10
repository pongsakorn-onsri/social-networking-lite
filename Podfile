platform :ios, '13.0'
source 'https://github.com/CocoaPods/Specs.git'
inhibit_all_warnings!

target 'SocialLite' do
  use_frameworks!

  # UI
  pod 'MaterialComponents'
  pod 'EmptyDataSet-Swift', '~> 5.0.0'
  pod 'GoogleSignIn'
  
  # Validation
  pod 'ValidatedPropertyKit'
  
  # Clean Architecture
  pod 'MGArchitecture', '~> 2.0.1'
  pod 'MGLoadMore', '~> 3.0.2'
  pod 'Dto'
  pod 'Resolver'
  
  # Base
  pod 'Firebase', :subspecs => ['Auth', 'RemoteConfig', "Firestore", 'Storage']
  pod 'XCoordinator/RxSwift', '~> 2.0.3'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'RxDataSources'
  pod 'RxGesture'

  target 'SocialLiteTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
    pod 'RxTest'
  end

  target 'SocialLiteUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
