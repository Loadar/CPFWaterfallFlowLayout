# CPFWaterfallFlowLayout
Swift瀑布流布局


## 使用方法

```Swift
// 支持Pods
pod 'CPFWaterfallFlowLayout', '~>2.0.1'
```

```Swift
// 引入对应模块
import CPFWaterfallFlowLayout
```

> 默认2列，~~暂不支持水平方向滑动~~, **已支持水平方向滑动**

## 示例

```Swift
// layout继承自UICollectionViewFlowLayout，属性配置相同
let layout = WaterfallLayout()
layout.minimumLineSpacing = 10
layout.minimumInteritemSpacing = 5
layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
layout.scrollDirection = .vertical

// 可指定全局列数, delegate方法返回的列数优先
layout.columnCount = 3

// header粘附效果
layout.stickyHeaders = true
// header粘附时允许的偏移
// 大于0时，header粘附时可超出view边界；小于0时，header粘附状态与view边界会保持一段距离
layout.stickyHeaderIgnoreOffset = 30

// cell最小高度
layout.minHeight = 100
// cell最大高度，默认为屏幕高度
layout.maxHeight = 500

// cell最小宽度(水平滚动时)
layout.minWidth = 100
// cell最大宽度(水平滚动时)，默认为屏幕宽度
layout.maxWidth = 500

```

```Swift
// 实现delegate方法可指定每个section列数(水平滚动下为行数)
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnForSection section: Int) -> Int {
    return section + 2
}

```

```Swift
// 随机size大小, 此delegate返回的size仅提供宽高比例
// 垂直滚动时，cell宽度由view bounds、contentInset(left, right), sectionInsets(left, right), interSpacing(min), 列数决定，确定宽度后，有宽高比例计算出高度；水平滚动类似
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if let size = sizeMap[indexPath] { return size }
    let size = CGSize(width: 100, height: random(in: 50..<200))
    sizeMap[indexPath] = size
    return size
}
```


