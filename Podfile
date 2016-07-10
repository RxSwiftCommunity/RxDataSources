platform :ios, '8.0'
use_frameworks!

target 'RxDataSources' do
    pod 'RxSwift', '~> 2.4'
    pod 'RxCocoa', '~> 2.4'
end

target 'Example' do
  pod 'RxSwift', '~> 2.4'
  pod 'RxCocoa', '~> 2.4'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
    end
  end
end

