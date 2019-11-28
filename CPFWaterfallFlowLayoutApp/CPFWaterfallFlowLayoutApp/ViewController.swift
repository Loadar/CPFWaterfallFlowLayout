//
//  ViewController.swift
//  CPFWaterfallFlowLayoutApp
//
//  Created by Aaron on 2018/3/14.
//  Copyright © 2018年 Aaron. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, WaterfallLayoutDelegate{

    let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
    class var layout: UICollectionViewFlowLayout {
        let layout = WaterfallLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 30, left: 10, bottom: 50, right: 10)
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 130)
        
        layout.stickyHeaders = false
        layout.stickyHeaderIgnoreOffset = -80
        layout.maxHeight = 500
        
//        layout.scrollDirection = .horizontal
//        layout.headerReferenceSize = CGSize(width: 100, height: 200)
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20)
//
//        layout.maxWidth = UIScreen.main.bounds.height
//
        layout.footerReferenceSize = CGSize(width: 1000, height: 100)
        return layout
    }
    
    var sizeMap: [IndexPath: CGSize] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        self.automaticallyAdjustsScrollViewInsets = false
        
        collectionView.backgroundColor = .white
        
        let frame = view.bounds
//        frame.size.height = 400
//        frame.origin.y = 100
        collectionView.frame = frame
        collectionView.backgroundColor = UIColor.lightGray
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: String(describing: self))
        collectionView.register(CPFHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(CPFHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")

        collectionView.contentInset = UIEdgeInsets(top: 20, left: 40, bottom: 2130, right: 50)
        collectionView.alwaysBounceVertical = true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100000
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: self), for: indexPath)
        cell.backgroundColor = .purple
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnForSection section: Int) -> Int {
        return section + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = sizeMap[indexPath] { return size }
        
        let value = 100
        let otherValue = random(in: 20..<1000)
        var size = CGSize(width: value, height: otherValue)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout, layout.scrollDirection == .horizontal {
            size = CGSize(width: otherValue, height: value)
        }
        sizeMap[indexPath] = size
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let sectionInsets = layout.sectionInset
        
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
            footer.backgroundColor = indexPath.section % 2 == 0 ? UIColor.blue.withAlphaComponent(0.5) : UIColor.yellow.withAlphaComponent(0.5)
            (footer as? CPFHeader)?.label.text = "\(indexPath.section)"
            
            let aView = footer.viewWithTag(333)
            if aView == nil {
                let extraView = UIView()
                extraView.tag = 333
                extraView.backgroundColor = UIColor.brown.withAlphaComponent(0.5)
                footer.addSubview(extraView)
                footer.clipsToBounds = false
                if layout.scrollDirection == .horizontal {
                    extraView.frame = CGRect(x: -sectionInsets.right, y: 0, width: sectionInsets.right, height: layout.footerReferenceSize.height)
                } else {
                    extraView.frame = CGRect(x: 0, y: -sectionInsets.bottom, width: layout.footerReferenceSize.width, height: sectionInsets.bottom)
                }
            }
            return footer
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
        header.backgroundColor = indexPath.section % 2 == 0 ? UIColor.green.withAlphaComponent(0.5) : UIColor.red.withAlphaComponent(0.5)
        (header as? CPFHeader)?.label.text = "\(indexPath.section)"
        
        let aView = header.viewWithTag(444)
        if aView == nil {
            let extraView = UIView()
            extraView.tag = 444
            extraView.backgroundColor = UIColor.cyan.withAlphaComponent(0.5)
            header.addSubview(extraView)
            header.clipsToBounds = false
            
            if layout.scrollDirection == .horizontal {
                extraView.frame = CGRect(x: layout.headerReferenceSize.width, y: 0, width: sectionInsets.left, height: layout.headerReferenceSize.height)
            } else {
                extraView.frame = CGRect(x: 0, y: layout.headerReferenceSize.height, width: layout.headerReferenceSize.width, height: sectionInsets.top)
            }
        }

        return header
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    func random(in range: Range<Int>) -> Int {
        let count = UInt32(range.upperBound - range.lowerBound)
        return  Int(arc4random_uniform(count)) + range.lowerBound
    }
}


class CPFHeader: UICollectionReusableView {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(label)
        var rect = self.bounds
        rect.origin.x = 10
        rect.size.width -= 10
        label.frame = rect
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
