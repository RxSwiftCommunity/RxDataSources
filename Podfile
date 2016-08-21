platform :ios, '8.0'
use_frameworks!

def common
    pod 'RxSwift', :git => 'git@github.com:ReactiveX/RxSwift.git', :branch => 'swift-3.0'
    pod 'RxCocoa', :git => 'git@github.com:ReactiveX/RxSwift.git', :branch => 'swift-3.0'
end

target 'RxDataSources' do
    common
end

target 'Example' do
    common
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
        #config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
    end
  end
end

