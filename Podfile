platform :ios, '8.0'
use_frameworks!

def common
    pod 'RxSwift', :git => 'https://github.com/ReactiveX/RxSwift.git', :branch => 'master'
    pod 'RxCocoa', :git => 'https://github.com/ReactiveX/RxSwift.git', :branch => 'master'
end

target 'RxDataSources-iOS' do
    common
end

target 'RxDataSources-tvOS' do
    common
end

target 'Tests' do
    common
end

target 'Example' do
    common
end
