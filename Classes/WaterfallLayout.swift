//
//  WaterfallLayout.swift
//  CPFWaterfallFlowLayout
//
//  Created by Aaron on 2018/3/14.
//  Copyright © 2018年 Aaron. All rights reserved.
//

import UIKit

public class WaterfallLayout: UICollectionViewFlowLayout {
    /// header粘附效果, 默认false
    public var stickyHeaders = false
    // 粘附header可以忽略高度；忽略的部分在header粘附时可以超出view边界
    public var stickyHeaderIgnoreOffset: CGFloat = 0
    /// 全局列数(水平滚动时指行数)(未实现delegate方法时), 默认为2
    public var columnCount = 2
    
    // 高度限制，为0表示不限制
    public var minHeight: CGFloat = 0
    public var maxHeight: CGFloat = UIScreen.main.bounds.height
    // 水平滚动时使用width
    public var minWidth: CGFloat = 0
    public var maxWidth: CGFloat = UIScreen.main.bounds.width
    
    /// 是否为数据附加模式，为true时数据增加时，仅计算新增项的layout attributes
    public var appending = false
    /// 强制布局，会忽略appending属性，仅作用一次
    public var forceLayout = false
    /// 分页，指定此值以判断是否为附加，其他情况由调用方设置forceLayout解决
    public var pageSize: Int?
    
    private var layoutRequired = true
    
    // 最小Content height(水平滚动时为width), 为0表示不限制
    public var minContentHeight: CGFloat = 0
    
    // section数据
    private var sectionItemList = [CPFSectionItem]()
    
    // MARK: - Overrides
    // 返回collectionView的contentSize
    override public var collectionViewContentSize: CGSize {
        guard let collectionView = self.collectionView else { return CGSize(width: 0, height: minContentHeight) }
        guard let lastSectionRect = sectionItemList.last?.frame else { return CGSize(width: 0, height: minContentHeight) }
        
        let rect = collectionView.bounds.inset(by: collectionView.contentInset)
        if self.scrollDirection == .horizontal {
            var width = ceil(lastSectionRect.maxX)
            if minContentHeight > 0 {
                width = max(width, minContentHeight)
            }
            return CGSize(width: width, height: rect.height)
        }
        
        var height = ceil(lastSectionRect.maxY)
        if minContentHeight > 0 {
            height = max(height, minContentHeight)
        }
        return CGSize(width: rect.width, height: height)
    }
    
    public var actualContentSize: CGSize {
        guard let collectionView = self.collectionView else { return .zero }
        guard let lastSectionRect = sectionItemList.last?.frame else { return .zero }
        
        let rect = collectionView.bounds.inset(by: collectionView.contentInset)
        if self.scrollDirection == .horizontal {
            let width = ceil(lastSectionRect.maxX)
            return CGSize(width: width, height: rect.height)
        }
        
        let height = ceil(lastSectionRect.maxY)
        return CGSize(width: rect.width, height: height)
    }
    
    public override func invalidateLayout() {
        if forceLayout {
            forceLayout = false
            sectionItemList.removeAll()
        } else if appending, let collectionView = self.collectionView, collectionView.numberOfSections == 1 {
            let itemCount = collectionView.numberOfItems(inSection: 0)
            if let aItem = sectionItemList.first {
                if let pageSize = self.pageSize, itemCount <= pageSize {
                    // 需要重置
                    sectionItemList.removeAll()
                } else if aItem.numberOfItems >= itemCount {
                    // 需要重置
                    sectionItemList.removeAll()
                } else {
                    // 保持当前数据
                }
            } else {
                // 保持当前数据
            }
        } else {
            sectionItemList.removeAll()
        }
        layoutRequired = true
        super.invalidateLayout()
    }
    
    // 准备更新layout
    override public func prepare() {
        defer { super.prepare() }
        
        guard layoutRequired else { return }
        layoutRequired = false
        
        guard let collectionView = self.collectionView else { return }
        
        // 确定section
        let sectionCount = collectionView.numberOfSections
        for aSection in 0..<sectionCount {
            let itemCount = collectionView.numberOfItems(inSection: aSection)
            prepareLayout(in: aSection, itemCount: itemCount)
        }
    }
    
    // 返回指定indexPath的header or footer view 属性
    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard (0..<sectionItemList.endIndex).contains(indexPath.section) else { return nil }
        let sectionItem = sectionItemList[indexPath.section]
        if elementKind == UICollectionView.elementKindSectionFooter {
            return sectionItem.footerAttributes
        }
        return sectionItem.headerAttributes
    }

    // 返回指定indexPath的item 属性
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard (0..<sectionItemList.endIndex).contains(indexPath.section) else { return nil }
        let sectionItem = sectionItemList[indexPath.section]
        return sectionItem.layoutAttributesInfo[indexPath]
    }

    // 指定区域内items属性
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return visibleLayoutAttributes(in: rect)
    }

    // collection view frame 变化时是否更新layout
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    // MARK: - Private Methods
    // 处理指定section的layout
    private func prepareLayout(in section: Int, itemCount: Int) {
        guard let collectionView = self.collectionView else { return }
        
        let viewRect = collectionView.bounds.inset(by: collectionView.contentInset)
        
        let sectionItem: CPFSectionItem
        if appending, sectionItemList.count > section {
            sectionItem = sectionItemList[section]
        } else {
            sectionItem = CPFSectionItem()
            sectionItem.index = section
            sectionItem.direction = scrollDirection
            sectionItemList.append(sectionItem)
        }
        sectionItem.headerAttributes = nil
        sectionItem.footerAttributes = nil
        
        var numberOfItemToAdd = itemCount
        if appending, sectionItem.numberOfItems > 0 {
            numberOfItemToAdd = itemCount - sectionItem.numberOfItems
        }
        sectionItem.numberOfItems = itemCount
        
        let indexPath = IndexPath(item: 0, section: section)
        let previousSectionRect = frame(of: section - 1)
        var sectionRect = CGRect.zero
        if self.scrollDirection == .horizontal {
            sectionRect.origin.x = previousSectionRect.maxX
            sectionRect.size.height = viewRect.height
        } else {
            sectionRect.origin.y = previousSectionRect.maxY
            sectionRect.size.width = viewRect.width
        }
        
        // header
        var headerSize = self.headerReferenceSize
        let delegate = collectionView.delegate as? WaterfallLayoutDelegate
        if let finalHeaderSize = delegate?.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) {
            headerSize = finalHeaderSize
        }
        if headerSize != .zero {
            var headerFrame = CGRect.zero
            if self.scrollDirection == .horizontal {
                headerFrame.origin.x = sectionRect.origin.x
            } else {
                headerFrame.origin.y = sectionRect.origin.y
            }
            headerFrame.size = headerSize
            
            let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: indexPath)
            headerAttributes.frame = headerFrame
            sectionItem.headerAttributes = headerAttributes
        }
        
        // sectionInsets
        var insets = self.sectionInset
        if let finalInsets = delegate?.collectionView?(collectionView, layout: self, insetForSectionAt: section) {
            insets = finalInsets
        }
        sectionItem.insets = insets
        
        // column count
        var columnCount = self.columnCount
        if let finalColumn = delegate?.collectionView?(collectionView, layout: self, columnForSection: section) {
            columnCount = finalColumn
        }
        sectionItem.columnCount = columnCount
        for aColumn in 0..<columnCount {
            if sectionItem.columnInfo[aColumn] != nil { continue }
            
            let item = CPFColumnItem()
            item.index = aColumn
            sectionItem.columnInfo[aColumn] = item
        }
        
        // space
        var lineSpacing = self.minimumLineSpacing
        if let space = delegate?.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) {
            lineSpacing = space
        }
        var interitemSpacing = self.minimumInteritemSpacing
        if let space = delegate?.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) {
            interitemSpacing = space
        }
        
        // 确定宽度
        var totalWidth = viewRect.width
        // 去掉左右边距
        totalWidth -= insets.left + insets.right
        if scrollDirection == .horizontal {
            totalWidth = viewRect.height
            totalWidth -= insets.top + insets.bottom
        }
        // 去掉间距
        if columnCount > 1 {
            totalWidth -= interitemSpacing * CGFloat(columnCount - 1)
        }
        let columnWidth = floor(totalWidth / CGFloat(columnCount))
        
        // item
        for aItem in (itemCount - numberOfItemToAdd)..<itemCount {
            let itemPath = IndexPath(item: aItem, section: section)
            let currentColumn = sectionItem.preferredColumn
            let currentRow = sectionItem.itemCount(in: currentColumn)
            
            var lastItemMaxY = sectionItem.maxY(of: currentColumn)
            if currentRow == 0, sectionItem.headerAttributes == nil {
                lastItemMaxY += scrollDirection == .horizontal ? sectionRect.maxX : sectionRect.maxY
            }
            
            var itemRect = CGRect.zero
            itemRect.size.width = columnWidth
            itemRect.size.height = columnWidth
            if scrollDirection == .horizontal {
                itemRect.origin.x = lastItemMaxY + (currentRow > 0 ? lineSpacing : 0)
                itemRect.origin.y = insets.top + CGFloat(currentColumn) * (interitemSpacing + columnWidth)
            } else {
                itemRect.origin.x = insets.left + CGFloat(currentColumn) * (interitemSpacing + columnWidth)
                itemRect.origin.y = lastItemMaxY + (currentRow > 0 ? lineSpacing : 0) // 非首行增加行间距
            }
            
            if let itemSize = delegate?.collectionView?(collectionView, layout: self, sizeForItemAt: itemPath), itemSize != .zero {
                // 按宽高比例确定最终的item高度
                if scrollDirection == .horizontal {
                    itemRect.size.width = columnWidth * itemSize.width / itemSize.height
                } else {
                    itemRect.size.height = columnWidth * itemSize.height / itemSize.width
                }
            }
            // 高度限制
            if scrollDirection == .horizontal {
                if minWidth > 0, itemRect.size.width < minWidth {
                    itemRect.size.width = minWidth
                }
                if maxWidth > 0, maxWidth > minWidth, itemRect.size.width > maxWidth {
                    itemRect.size.width = maxWidth
                }
            } else {
                if minHeight > 0, itemRect.size.height < minHeight {
                    itemRect.size.height = minHeight
                }
                if maxHeight > 0, maxHeight > minHeight, itemRect.size.height > maxHeight {
                    itemRect.size.height = maxHeight
                }
            }
            
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: itemPath)
            itemAttributes.frame = itemRect
            sectionItem.columnInfo[currentColumn]?.layoutAttributes.append(itemAttributes)
            sectionItem.layoutAttributesInfo[itemPath] = itemAttributes
        }
        
        let itemMaxY = sectionItem.maxY
        
        // footer
        var footerSize = self.footerReferenceSize
        if let finalFooterSize = delegate?.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) {
            footerSize = finalFooterSize
        }
        if footerSize != .zero {
            var footerFrame = CGRect.zero
            if scrollDirection == .horizontal {
                footerFrame.origin.x = itemMaxY
            } else {
                footerFrame.origin.y = itemMaxY
            }
            footerFrame.size = footerSize
            
            let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: indexPath)
            footerAttributes.frame = footerFrame
            sectionItem.footerAttributes = footerAttributes
        }
        
        if scrollDirection == .horizontal {
            sectionRect.size.width = sectionItem.maxY - sectionRect.origin.x
        } else {
            sectionRect.size.height = sectionItem.maxY - sectionRect.origin.y
        }
        sectionItem.frame = sectionRect
    }
    
    // 获取指定section的区域
    private func frame(of section: Int) -> CGRect {
        guard (0..<sectionItemList.count).contains(section) else { return CGRect.zero }
        return sectionItemList[section].frame
    }
    
    // MARK: - Show Attributes Methods
    // 获取visible cell layout attributes
    private func visibleLayoutAttributes(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        guard let _ = self.collectionView else { return [] }
        guard sectionItemList.count > 0 else { return [] }

        var attributes = [UICollectionViewLayoutAttributes]()
        let indexes = sectionIndexes(in: rect)

        let context = self.invalidationContext(forBoundsChange: rect)
        (context as? UICollectionViewFlowLayoutInvalidationContext)?.invalidateFlowLayoutAttributes = false

        for section in indexes {
            guard (0..<sectionItemList.count).contains(section) else { continue }

            let sectionItem = sectionItemList[section]
            //let info = sectionItem.layoutAttributesInfo
            
            for (_, columnItem) in sectionItem.columnInfo {
                guard !columnItem.layoutAttributes.isEmpty else { continue }
                
                var start = 0
                var end = columnItem.layoutAttributes.endIndex
                
                var found: Int?
                repeat {
                    let middle = (start + end) / 2
                    if rect.intersects(columnItem.layoutAttributes[middle].frame) {
                        found = middle
                        break
                    }
                    if scrollDirection == .horizontal {
                        if rect.maxX < columnItem.layoutAttributes[middle].frame.minX {
                            end = middle
                        } else {
                            start = middle + 1
                        }
                    } else {
                        if rect.maxY < columnItem.layoutAttributes[middle].frame.minY {
                            end = middle
                        } else {
                            start = middle + 1
                        }
                    }
                    
                } while start < end
                
                guard let theIndex = found else { continue }
                
                // 向前
                for i in (0..<theIndex).reversed() {
                    if rect.intersects(columnItem.layoutAttributes[i].frame) {
                        attributes.append(columnItem.layoutAttributes[i])
                    } else {
                        break
                    }
                }
                
                // 向后
                for i in theIndex..<columnItem.layoutAttributes.endIndex {
                    if rect.intersects(columnItem.layoutAttributes[i].frame) {
                        attributes.append(columnItem.layoutAttributes[i])
                    } else {
                        break
                    }
                }
            }

            // footer
            if let footerAttributes = sectionItem.footerAttributes {
                if rect.intersects(footerAttributes.frame) {
                    attributes.append(footerAttributes)
                }
            }

            // header
            if let headerAttributes = sectionItem.headerAttributes {
                if !stickyHeaders {
                    if rect.intersects(headerAttributes.frame) {
                        attributes.append(headerAttributes)
                    }
                } else {
                    // header粘附的判断
                    updateHeader(attributes: headerAttributes, sectionItem: sectionItem)
                    attributes.append(headerAttributes)

                    // 设置header layout需要更新
                    context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader, at: [headerAttributes.indexPath])
                }
            }
        }

        return attributes
    }
    
    // 获取visible cell indexPath list
    private func sectionIndexes(in rect: CGRect) -> [Int] {
        guard let collectionView = self.collectionView else { return [] }

        var indexes = [Int]()
        let sectionCount = collectionView.numberOfSections
        for section in 0..<sectionCount {
            guard (0..<sectionItemList.count).contains(section) else { continue }
            let sectionRect = sectionItemList[section].frame
            let isVisible = rect.intersects(sectionRect)
            if isVisible {
                indexes.append(section)
            }
        }
        return indexes
    }
    
    // MARK: - Sticky Header implementation methods
    // 更新Header
    private func updateHeader(attributes: UICollectionViewLayoutAttributes, sectionItem: CPFSectionItem) {
        // header本身，不处理
        guard let collectionView = self.collectionView else { return }
        
        let viewRect = collectionView.bounds
        // header显示在上层，给zIndex一个较大的值
        attributes.zIndex = 999
        attributes.isHidden = false
        
        var finalFrame = attributes.frame
        var previousMaxY: CGFloat = 0
        if (0..<sectionItemList.count).contains(sectionItem.index - 1) {
            let item = sectionItemList[sectionItem.index - 1]
            previousMaxY = item.maxY
        }
        // 旧的header垂直偏移
        let oldY = previousMaxY
        // 当前section最大可达的垂直偏移(header不能超出当前section)
        let sectionMaxY = sectionItem.maxY
        // view顶部垂直偏移(header紧贴上边界)
        let viewY = scrollDirection == .horizontal ? viewRect.minX : viewRect.minY
        // 保持上下边界在view上，在section内
        let height = scrollDirection == .horizontal ? finalFrame.width : finalFrame.height
        var finalY = min(max(viewY - stickyHeaderIgnoreOffset, oldY), sectionMaxY - height)
        let section = attributes.indexPath.section
        if section > 0, (0..<sectionItemList.count).contains(section - 1) {
            // 不能覆盖在前面的section上
            let previousSectionItem = sectionItemList[section - 1]
            finalY = max(finalY, previousSectionItem.maxY)
        }
        
        if scrollDirection == .horizontal {
            finalFrame.origin.x = finalY
        } else {
            finalFrame.origin.y = finalY
        }
        attributes.frame = finalFrame
    }
}
