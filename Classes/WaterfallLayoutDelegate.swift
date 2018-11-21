//
//  WaterfallLayoutDelegate.swift
//  CPFWaterfallFlowLayout
//
//  Created by Aaron on 2018/3/14.
//  Copyright © 2018年 Aaron. All rights reserved.
//

import UIKit

/// Waterfall layout delegate, 继承自UICollectionViewDelegateFlowLayout
@objc public protocol WaterfallLayoutDelegate: UICollectionViewDelegateFlowLayout {
    
     /// 返回指定section的列数(水平滚动时返回的是行数), 可选方法
     /// 未实现时, 所有section列数一致, 数值可修改layout的columnCount属性
     ///
     /// - Parameters:
     ///   - collectionView: 当前collectionView
     ///   - collectionViewLayout: 当前layout
     ///   - section: 当前section
     /// - Returns: 列数
     @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnForSection section: Int) -> Int
}
