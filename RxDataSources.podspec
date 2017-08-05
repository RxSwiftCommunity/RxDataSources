Pod::Spec.new do |s|
  s.name             = "RxDataSources"
  s.version          = "2.0.0"
  s.summary          = "This is a collection of reactive data sources for UITableView and UICollectionView."
  s.description      = <<-DESC
This is a collection of reactive data sources for UITableView and UICollectionView.

It enables creation of animated data sources for table an collection views in just a couple of lines of code.

```swift
let data: Observable<Section> = ...

let dataSource = RxTableViewSectionedAnimatedDataSource<Section>()
dataSource.cellFactory = { (tv, ip, i) in
    let cell = tv.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style:.Default, reuseIdentifier: "Cell")
    cell.textLabel!.text = "\(i)"
    return cell
}

// animated
data
    .bind(to: animatedTableView.rx.items(dataSource: dataSource))
    .disposed(by: disposeBag)

// normal reload
data
    .bind(to: tableView.rx.items(dataSource: dataSource))
    .disposed(by: disposeBag)
```
                        DESC

  s.subspec 'Diffing' do |ds|
    ds.source_files = 'Sources/Differentiator/**/*.swift'
  end

  s.subspec 'Default' do |cs|
    cs.dependency 'RxDataSources/Diffing'
    cs.source_files = 'Sources/RxDataSources/*.swift'
  end

  s.homepage         = "https://github.com/ReactiveX/RxSwift"
  s.license          = 'MIT'
  s.author           = { "Krunoslav Zaher" => "krunoslav.zaher@gmail.com" }
  s.source           = { :git => "https://github.com/RxSwiftCommunity/RxDataSources.git", :tag => s.version.to_s }

  s.default_subspec = 'Default'
  s.requires_arc          = true

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.dependency 'RxSwift', '~> 3.0'
  s.dependency 'RxCocoa', '~> 3.0'
end
