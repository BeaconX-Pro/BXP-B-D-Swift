//
//  MKBXDAlarmV2Model.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

@MainActor
public final class MKBXDAlarmV2Model: NSObject {

    public var singleIsOn: Bool = false
    public var doubleIsOn: Bool = false
    public var longIsOn: Bool = false
    public var inactivityIsOn: Bool = false

    public var alarmEventCount: String = ""

    public func readData(sucBlock: @escaping () -> Void,
                         failedBlock: @escaping (Error) -> Void) {
        MKBXDInterface.bxd_readTriggerChannelState(sucBlock: { [weak self] returnData in
            guard let self = self else { return }
            let result = (returnData as? [String: Any])?["result"] as? [String: Any] ?? [:]
            self.singleIsOn = (result["singlePressMode"] as? Bool) ?? false
            self.doubleIsOn = (result["doublePressMode"] as? Bool) ?? false
            self.longIsOn = (result["longPressMode"] as? Bool) ?? false
            self.inactivityIsOn = (result["abnormalInactivityMode"] as? Bool) ?? false
            sucBlock()
        }, failedBlock: { error in
            failedBlock(error)
        })
    }
}
