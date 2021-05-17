//
//  WaterfallLayout+Cpf.swift
//  CPFWaterfallFlowLayoutApp
//
//  Created by Aaron on 2021/5/17.
//  Copyright © 2021 Aaron. All rights reserved.
//

import Foundation
import CPFChain

extension Cpf where Base: WaterfallLayout {
    @discardableResult
    func columnCount(_ closour: @escaping (Int) -> (Int)) -> Self {
        base.columnCountProviding = closour
        return self
    }
}
