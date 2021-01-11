//
//  Bus+Wrapper.swift
//  NBus
//
//  Created by nuomi1 on 2021/1/4.
//  Copyright © 2021 nuomi1. All rights reserved.
//

import Foundation

public struct BusWrapper<Base> {

    public let base: Base

    public init(_ base: Base) {
        self.base = base
    }
}

public protocol BusCompatible {

    associatedtype BusBase

    var bus: BusWrapper<BusBase> { get set }
}

extension BusCompatible {

    public var bus: BusWrapper<Self> {
        get { BusWrapper(self) }
        set {}
    }
}
