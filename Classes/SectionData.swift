//
//  SectionData.swift
//  CPFWaterfallFlowLayout
//
//  Created by Aaron on 2018/3/14.
//  Copyright © 2018年 Aaron. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

/// 处理layout时的setion数据
class SectionData {
    var section = 0
    var rect = CGRect.zero
    var insets = UIEdgeInsets.zero
    var columnMap = [Int: [CGRect]]()
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    var supplementMap = [String: UICollectionViewLayoutAttributes]()
    
    /// 获得当前setion指定column的item数目
    func itemCount(inColumn column: Int) -> Int {
        guard columnMap[column] != nil else { return 0 }
        return columnMap[column]!.count
    }
    
    /// 获得当前section指定column的垂直方向最大偏移
    func bottom(forColumn column: Int) -> CGFloat {
        guard let rects = columnMap[column], rects.count > 0 else {
            guard let headerAttributes = supplementMap[UICollectionElementKindSectionHeader] else { return 0}
            return headerAttributes.frame.height
        }
        return rects.last!.maxY
    }
    
    /// 当前section的高度
    var height: CGFloat {
        var maxHeight = CGFloat(0)
        for (aColumn, _) in columnMap {
            let height = bottom(forColumn: aColumn)
            maxHeight = CGFloat.maximum(height, maxHeight)
        }
        return maxHeight
    }
    
    /// 当前section高度最小的列
    var preferredColumn: Int {
        var column = 0
        var height = CGFloat.infinity
        for (aColumn, _) in columnMap {
            let theHeight = bottom(forColumn: aColumn)
            if theHeight < height {
                height = theHeight
                column = aColumn
            } else if abs(theHeight - height) < 1e-6 {
                if aColumn < column {
                    column = aColumn
                }
            }
        }
        return column
    }    
}

