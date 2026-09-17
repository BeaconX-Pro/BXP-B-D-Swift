//
//  MKBXDSlotConfigDefines.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

// MARK: - Slot Type

/// SLOT 帧类型
/// - alarmInfo: Alarm info
/// - uid: UID
/// - beacon: iBeacon
public enum MKBXDSlotType: Int {
    case alarmInfo = 0
    case uid = 1
    case beacon = 2
}
