//
//  String.swift
//  ReadRate
//
//  Created by Evan Freeze on 2/14/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import Foundation

extension String {
    func cleanedNumeric() -> String {
        self.filter("0123456789.".contains).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
