//
//  WaterfallLayout+Cpf.swift
//  CPFWaterfallFlowLayoutApp
//
//  Created by Aaron on 2021/5/17.
//  Copyright © 2021 Aaron. All rights reserved.
//

import Foundation
import CPFChain

public extension Cpf where Base: WaterfallLayout {
    @discardableResult
    func columnCount(_ closour: @escaping (Int) -> (Int)) -> Self {
        base.columnCountProviding = closour
        return self
    }
}

public extension Cpf where Base: UICollectionView {
    @discardableResult
    func columnCount(_ closour: @escaping (Int) -> (Int)) -> Self {
        (base.collectionViewLayout as? WaterfallLayout)?.columnCountProviding = closour
        return self
    }
}
