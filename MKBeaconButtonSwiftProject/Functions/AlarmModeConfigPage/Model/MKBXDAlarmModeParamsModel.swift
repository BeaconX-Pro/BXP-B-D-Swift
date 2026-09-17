//
//  MKBXDAlarmModeParamsModel.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2026/9/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

import Foundation

import MKBaseSwiftModule

// MARK: - Trigger Channel Adv Params Model

/// 活跃通道广播参数
/// 对应 OC 的 `MKBXDTriggerChannelAdvParamsModel`（遵循 `MKBXDTriggerChannelAdvParamsProtocol`）
public final class MKBXDTriggerChannelAdvParamsModel: NSObject, MKBXDTriggerChannelAdvParamsProtocol {

    public var alarmType: MKBXDChannelAlarmType = .single

    /// 是否开启广播
    public var isOn: Bool = false

    /// Ranging data（-100dBm~0dBm）
    public var rssi: Int = 0

    /// 广播间隔（1~500，单位 20ms）
    public var advInterval: String = ""

    /// 发射功率
    public var txPower: MKBXDTxPower = .dBm40
}

// MARK: - Channel Trigger Params Model

/// 活跃通道触发参数
/// 对应 OC 的 `MKBXDChannelTriggerParamsModel`（遵循 `MKBXDChannelTriggerParamsProtocol`）
public final class MKBXDChannelTriggerParamsModel: NSObject, MKBXDChannelTriggerParamsProtocol {

    public var alarmType: MKBXDChannelAlarmType = .single

    /// 是否开启触发功能
    public var alarm: Bool = false

    /// Ranging data（-100dBm~0dBm）
    public var rssi: Int = 0

    /// 广播间隔（1~500，单位 20ms）
    public var advInterval: String = ""

    /// 触发后广播时长（1s~65535s）
    public var advertisingTime: String = ""

    /// 发射功率
    public var txPower: MKBXDTxPower = .dBm40
}

// MARK: - Alarm Mode Params Model（空壳）

/// 对应 OC 的 `MKBXDAlarmModeParamsModel`
public final class MKBXDAlarmModeParamsModel: NSObject {
}
