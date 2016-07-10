Pod::Spec.new do |s|
  s.name             = "RxDataSources"
  s.version          = "0.9"
  s.summary          = "This is a collection of reactive data sources for UITableView and UICollectionView."
  s.description      = <<-DESC
This is a collection of reactive data sources for UITableView and UICollectionView.

It enables creation of animated data sources for table an collection views in just a couple of lines of code.

```swift
let data: Obserable<Section> = ...

let dataSource = RxTableViewSectionedAnimatedDataSource<Section>()
dataSource.cellFactory = { (tv, ip, i) in
    let cell =tv.dequeueReusableCellWithIdentifier("Cell") ?? UITableViewCell(style:.Default, reuseIdentifier: "Cell")
    cell.textLabel!.text = "\(i)"
    return cell
}

// animated
data
   .bindTo(animatedTableView.rx_itemsAnimatedWithDataSource(dataSource))
   .addDisposableTo(disposeBag)

// normal reload
data
   .bindTo(tableView.rx_itemsWithDataSource(dataSource))
   .addDisposableTo(disposeBag)
```
                        DESC
  s.homepage         = "https://github.com/ReactiveX/RxSwift"
  s.license          = 'MIT'
  s.author           = { "Krunoslav Zaher" => "krunoslav.zaher@gmail.com" }
  s.source           = { :git => "https://github.com/RxSwiftCommunity/RxDataSources.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.source_files          = 'Sources/**/*.swift'

  s.dependency 'RxSwift', '~> 2.2'
  s.dependency 'RxCocoa', '~> 2.2'
end
