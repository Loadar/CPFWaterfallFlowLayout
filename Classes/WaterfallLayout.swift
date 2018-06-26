//
//  WaterfallLayout.swift
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

public class WaterfallLayout: UICollectionViewFlowLayout {
    /// header粘附效果, 默认false
    public var stickyHeaders = false
    // 粘附header可以忽略高度；忽略的部分在header粘附时可以超出view边界
    public var stickyHeaderIgnoreHeight: CGFloat = 0
    /// 全局列数(未实现delegate方法时), 默认为2
    public var columnCount = 2

    // section数据
    private var sectionDatas = [SectionData]()
    var currentEdgeInsets = UIEdgeInsets.zero
    
    // MARK: - Overrides
    // 返回collectionView的contentSize
    override public var collectionViewContentSize: CGSize {
        guard let lastSectionRect = sectionDatas.last?.rect else {
            return CGSize.zero
        }
        return CGSize(width: collectionView!.bounds.width, height: lastSectionRect.maxY)
    }
    
    // 准备更新layout
    override public func prepare() {
        sectionDatas.removeAll()
        
        let sections = collectionView!.numberOfSections;
        for aSection in 0 ..< sections {
            let items = collectionView!.numberOfItems(inSection: aSection)
            prepareLayout(inSection: aSection, numberOfItems: items)
        }
    }
    
    // 返回指定indexPath的header or footer view 属性
    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return sectionDatas[indexPath.section].supplementMap[elementKind]
    }
    
    // 返回指定indexPath的item 属性
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return sectionDatas[indexPath.section].layoutAttributes[indexPath.item]
    }
    
    // 指定区域内items属性
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return visibleLayoutAttributes(in: rect)
    }
    
    // collection view frame 变化时是否更新layout
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return self.stickyHeaders
    }
    
    // MARK: - Private Methods
    // 处理指定section的layout
    internal func prepareLayout(inSection section: Int, numberOfItems items: Int) {
        let aData = SectionData()
        aData.section = section
        sectionDatas.append(aData)
        
        let indexPath = IndexPath(item: 0, section: section)
        let previousSectionRect = rect(forSection: section - 1)
        var sectionRect = CGRect.zero
        sectionRect.origin.y = previousSectionRect.maxY
        sectionRect.size.width = collectionView!.bounds.size.width
        
        // header
        var headerSize = self.headerReferenceSize
        let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout
        if let theSize = delegate?.collectionView?(collectionView!, layout: self, referenceSizeForHeaderInSection: section) {
            // delegate实现了header相关方法
            headerSize = theSize
        }
        var headerFrame = CGRect.zero
        headerFrame.origin.y = sectionRect.origin.y
        headerFrame.size = headerSize
        var headerHeight = CGFloat(0.0)
        
        let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: indexPath)
        headerAttributes.frame = headerFrame
        headerHeight = headerSize.height
        aData.supplementMap[UICollectionElementKindSectionHeader] = headerAttributes
        
        // sectionInsets
        var insets = self.sectionInset
        if let theInsets = delegate?.collectionView?(collectionView!, layout: self, insetForSectionAt: section) {
            insets = theInsets
        }
        aData.insets = insets
        
        // space
        var lineSpacing = self.minimumLineSpacing
        if let space = delegate?.collectionView?(collectionView!, layout: self, minimumLineSpacingForSectionAt: section) {
            lineSpacing = space
        }
        var interitemSpacing = self.minimumInteritemSpacing
        if let space = delegate?.collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: section) {
            interitemSpacing = space
        }
        
        var itemsContentRect = CGRect.zero
        itemsContentRect.origin.x = insets.left;
        itemsContentRect.origin.y = headerHeight + insets.top;
        
        let theDelegate = delegate as? WaterfallLayoutDelegate
        
        var columns = columnCount
        if let theColumn = theDelegate?.collectionView?(collectionView!, layout: self, columnForSection: section) {
            columns = theColumn
        }
        itemsContentRect.size.width = collectionView!.frame.width - insets.left - insets.right
        let columnSpace = itemsContentRect.size.width - (interitemSpacing * (CGFloat(columns - 1)))
        let columnWidth = columnSpace / CGFloat(columns)
        for aColumn in 0 ..< columns {
            aData.columnMap[aColumn] = [CGRect]()
        }
        
        // item
        for aItem in 0 ..< items {
            let itemPath = IndexPath(item: aItem, section: section)
            let destColumn = aData.preferredColumn
            let destRow = aData.itemCount(inColumn: destColumn)
            var lastItemBottom = aData.bottom(forColumn: destColumn)
            if destRow == 0 {
                lastItemBottom += sectionRect.origin.y
            }
            
            var itemRect = CGRect.zero
            itemRect.origin.x = itemsContentRect.origin.x + CGFloat(destColumn) * (interitemSpacing + columnWidth)
            itemRect.origin.y = lastItemBottom + (destRow > 0 ? lineSpacing: insets.top)
            itemRect.size.width = columnWidth
            itemRect.size.height = columnWidth
            
            if let theSize = delegate?.collectionView!(collectionView!, layout: self, sizeForItemAt: itemPath) {
                // 按宽高比例确定最终的item高度
                itemRect.size.height = theSize.height * columnWidth / theSize.width
            }
            
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: itemPath)
            itemAttributes.frame = itemRect
            aData.layoutAttributes.append(itemAttributes)
            aData.columnMap[destColumn]?.append(itemRect)
        }
        
        itemsContentRect.size.height = aData.height + insets.bottom
        
        // footer
        var footerHeight = self.footerReferenceSize.height
        if let theSize = delegate?.collectionView?(collectionView!, layout: self, referenceSizeForFooterInSection: section) {
            var footerFrame = CGRect.zero
            footerFrame.origin.y = itemsContentRect.size.height
            footerFrame.size = theSize
            
            let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: indexPath)
            footerAttributes.frame = footerFrame
            footerHeight = footerFrame.size.height
            aData.supplementMap[UICollectionElementKindSectionFooter] = footerAttributes
        }
        
        if section > 0 {
            itemsContentRect.size.height -= sectionRect.origin.y
        }
        
        sectionRect.size.height = itemsContentRect.size.height + footerHeight
        aData.rect = sectionRect
    }
    
    // 获取指定section的区域
    internal func rect(forSection section: Int) -> CGRect {
        guard (0 ..< sectionDatas.count).contains(section) else {
            return CGRect.zero
        }
        return sectionDatas[section].rect
    }
    
    // MARK: - Show Attributes Methods
    // 获取visible cell layout attributes
    internal func visibleLayoutAttributes(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        var attributes = [UICollectionViewLayoutAttributes]()
        let indexes = sectionIndexes(in: rect)
        for aSection in indexes {
            
            let aData = sectionDatas[aSection]
            
            // items
            for itemAttributes in aData.layoutAttributes {
                itemAttributes.zIndex = 1
                if rect.intersects(itemAttributes.frame) {
                    attributes.append(itemAttributes)
                }
            }
            
            var insets = UIEdgeInsets.zero
            // footer
            let footerAttributes = aData.supplementMap[UICollectionElementKindSectionFooter]
            if footerAttributes != nil {
                if rect.intersects(footerAttributes!.frame) {
                    attributes.append(footerAttributes!)
                }
            } else {
                insets = aData.insets
            }
            self.currentEdgeInsets = insets
            
            // header
            let headerAttributes = aData.supplementMap[UICollectionElementKindSectionHeader]
            if headerAttributes != nil {
                if !stickyHeaders {
                    if rect.intersects(headerAttributes!.frame) {
                        attributes.append(headerAttributes!)
                    }
                    
                } else {
                    if let highestAttributes = aData.highestAttributes {
                        attributes.append(headerAttributes!)
                        updateHeader(attributes: headerAttributes!, lastCellAttributes: highestAttributes)
                    } else {
                        var finalRect = headerAttributes!.frame
                        finalRect.origin = rect.origin
                        headerAttributes?.frame = finalRect
                        attributes.append(headerAttributes!)
                    }
                }
            }
        }
        
        return attributes
    }
    
    // 获取visible cell indexPath list
    internal func sectionIndexes(in rect: CGRect) -> [Int] {
        var indexes = [Int]()
        let sectionCount = collectionView!.numberOfSections
        for section in 0 ..< sectionCount {
            let sectionRect = sectionDatas[section].rect
            let isVisible = rect.intersects(sectionRect)
            if isVisible {
                indexes.append(section)
            }
        }
        return indexes
    }
    
    
    // MARK: - Sticky Header implementation methods
    // 更新Header
    internal func updateHeader(attributes: UICollectionViewLayoutAttributes, lastCellAttributes: UICollectionViewLayoutAttributes) {
        let viewBounds = collectionView!.bounds
        // header显示在上层，给zIndex一个较大的值
        attributes.zIndex = 999
        attributes.isHidden = false
        
        var origin = attributes.frame.origin
        // 旧的header垂直偏移
        let oldY = origin.y
        // 当前section最大可达的垂直偏移(header不能超出当前section)
        let sectionMaxY = lastCellAttributes.frame.maxY - attributes.frame.height + self.currentEdgeInsets.bottom
        // view顶部垂直偏移(header紧贴上边界)
        let viewY = viewBounds.minY 
        // 保存上下边界在view上，在section内
        var finalY = CGFloat.minimum(CGFloat.maximum(viewY - stickyHeaderIgnoreHeight, oldY), sectionMaxY)
        let section = attributes.indexPath.section
        if section > 0 {
            // 不能覆盖在前面的section上
            let aData = sectionDatas[attributes.indexPath.section - 1]
            if let previousHighestAttributes = aData.highestAttributes {
                var insets = self.sectionInset
                let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout
                if let theInsets = delegate?.collectionView?(collectionView!, layout: self, insetForSectionAt: section) {
                    insets = theInsets
                }
                finalY = max(finalY, previousHighestAttributes.frame.maxY + insets.bottom)
            }
        }
        
        origin.y = finalY
        
        var finalRect = attributes.frame
        finalRect.origin = origin
        attributes.frame = finalRect
    }
}
