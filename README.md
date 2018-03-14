# CPFWaterfallFlowLayout
Swift瀑布流布局


## 使用方法

```Swift
// 支持Pods
pod 'CPFWaterfallFlowLayout', '~>0.0.1'
```

```Swift
// 引入对应模块
import CPFWaterfallFlowLayout
```

> 默认2列，暂不支持水平方向滑动

## 示例

```Swift
// layout继承自UICollectionViewFlowLayout，属性配置相同
let layout = WaterfallLayout()
layout.minimumLineSpacing = 10
layout.minimumInteritemSpacing = 5
layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
layout.scrollDirection = .vertical

// 可指定全局列数
layout.columnCount = 3

// header粘附效果
layout.stickyHeaders = true
```

```Swift
// 实现delegate方法可指定每个section列数
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnForSection section: Int) -> Int {
    return section + 2
}

```

```Swift
// 随机size大小
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if let size = sizeMap[indexPath] { return size }
    let size = CGSize(width: 100, height: random(in: 50..<200))
    sizeMap[indexPath] = size
    return size
}
```


