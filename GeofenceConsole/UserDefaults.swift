//
//  UserDefaults.swift
//  GeofenceConsole
//
//  Created by AGDC Dev3 on 2017/12/17.
//  Copyright © 2017年 moaible. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let arrowsBackground = DefaultsKey<Bool>("arrowsBackground")
    static let accuracySegmentIndex = DefaultsKey<Int>("accuracySegmentIndex")
    static let reportDistanceValue = DefaultsKey<Double?>("reportDistanceValue")
}
