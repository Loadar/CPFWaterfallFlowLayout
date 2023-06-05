//
//  WaterfallLayout+Cpf.swift
//  CPFWaterfallFlowLayoutApp
//
//  Created by Aaron on 2021/5/17.
//  Copyright © 2021 Aaron. All rights reserved.
//

import UIKit
import CPFChain

public extension Cpf where Wrapped: WaterfallLayout {
    @discardableResult
    func columnCount(_ closour: @escaping (Int) -> (Int)) -> Self {
        wrapped.columnCountProviding = closour
        return self
    }
}

public extension Cpf where Wrapped: UICollectionView {
    @discardableResult
    func columnCount(_ closour: @escaping (Int) -> (Int)) -> Self {
        (wrapped.collectionViewLayout as? WaterfallLayout)?.columnCountProviding = closour
        return self
    }
}
