//
//  Double.swift
//  ReadRate
//
//  Created by Evan Freeze on 2/12/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import Foundation

extension Double {
    func asRoundedPercent() -> String {
        "\(Int((self * 100).rounded()))%"
    }
}
