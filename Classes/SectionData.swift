//
//  SectionData.swift
//  CPFWaterfallFlowLayout
//
//  Created by Aaron on 2018/3/14.
//  Copyright © 2018年 Aaron. All rights reserved.
//

import UIKit

class CPFColumnItem {
    var index: Int = 0
    var layoutAttributes: [UICollectionViewLayoutAttributes] = []
}

class CPFSectionItem {
    var index: Int = 0
    var frame: CGRect = .zero
    var insets: UIEdgeInsets = .zero
    // 列表滚动方向
    var direction: UICollectionView.ScrollDirection = .vertical
    // 列(水平方向滚动时，为行)
    var columnCount = 1
    var columnInfo: [Int: CPFColumnItem] = [:]
    // header & footer
    var headerAttributes: UICollectionViewLayoutAttributes?
    var footerAttributes: UICollectionViewLayoutAttributes?
    
    var numberOfItems = 0
    
    /// 指定column的item数目(水平方向滚动时，为指定row的item数目)
    func itemCount(in column: Int) -> Int {
        return columnInfo[column]?.layoutAttributes.count ?? 0
    }

    /// 指定column垂直方向最大偏移(水平方向滚动时，为水平方向最大偏移)
    func maxY(of column: Int) -> CGFloat {
        // 检查列数据, 查找最后一个item
        if let rect = columnInfo[column]?.layoutAttributes.last?.frame {
            return direction == .horizontal ? rect.maxX : rect.maxY
        }
        // 检查header
        if let attributes = headerAttributes {
            return direction == .horizontal ? attributes.frame.maxX + insets.left : attributes.frame.maxY + insets.top
        }
        return direction == .horizontal ? insets.left : insets.top
    }
    
    /// 当前section的垂直方向的最大偏移(水平方向滚动时，为水平方向最大偏移)
    var maxY: CGFloat {
        // 检查footer
        if let attributes = footerAttributes {
            return direction == .horizontal ? attributes.frame.maxX : attributes.frame.maxY
        }
        // 检查列数据
        var maxHeight: CGFloat = 0
        for (aColumn, _) in columnInfo {
            let height = maxY(of: aColumn)
            maxHeight = max(height, maxHeight)
        }
        
        let insetValue = direction == .horizontal ? insets.right : insets.bottom
        return maxHeight + insetValue
    }
    
    /// 当前section高度最小的列(水平方向滚动时，为行)
    var preferredColumn: Int {
        var column = 0
        var height = CGFloat.infinity
        
        for (aColumn, _) in columnInfo {
            let columnHeight = maxY(of: aColumn)
            if columnHeight < height {
                height = columnHeight
                column = aColumn
            } else if abs(columnHeight - height) < 1e-6 {
                // 高度相同时，取较小的列
                if aColumn < column {
                    column = aColumn
                }
            }
        }
        return column
    }
    
    var layoutAttributesInfo: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    
    var layoutAttributesWithMaxY: UICollectionViewLayoutAttributes? {
        // 检查footer
        if let attributes = footerAttributes { return attributes }
        
        // 找各列最小的
        var attributes: UICollectionViewLayoutAttributes?
        for (_, columnItem) in columnInfo {
            guard let lastAttributes = columnItem.layoutAttributes.last else { continue }
            if let previousAttributes = attributes {
                if direction == .horizontal {
                    if previousAttributes.frame.maxX < lastAttributes.frame.maxX {
                        attributes = lastAttributes
                    }
                } else {
                    if previousAttributes.frame.maxY < lastAttributes.frame.maxY {
                        attributes = lastAttributes
                    }
                }
            } else {
                attributes = lastAttributes
            }
        }
        
        // 无item时返回header
        return attributes ?? headerAttributes
    }
}
