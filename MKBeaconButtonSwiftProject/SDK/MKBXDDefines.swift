//
//  MKBXDDefines.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2025/5/18.
//

import Foundation

// MARK: - 枚举定义

/// 通道告警类型
public enum MKBXDChannelAlarmType: Int {
    /// 单击
    case single = 0
    /// 双击
    case double
    /// 长按
    case long
    /// 异常静止
    case abnormalInactivity
}

/// 通道告警提醒类型
public enum MKBXDChannelAlarmNotifyType: Int {
    /// 单击
    case single = 0
    /// 双击
    case double
    /// 长按
    case long
    /// 异常静止
    case abnormalInactivity
    /// 长连接模式（V1 不支持）
    case longConMode
}

/// 发射功率
public enum MKBXDTxPower: Int {
    /// -40dBm
    case dBm40 = 0
    /// -20dBm
    case neg20dBm
    /// -16dBm
    case neg16dBm
    /// -12dBm
    case neg12dBm
    /// -8dBm
    case neg8dBm
    /// -4dBm
    case neg4dBm
    /// 0dBm
    case zero0dBm
    /// 3dBm
    case three3dBm
    /// 4dBm
    case four4dBm
}

/// 提醒类型
public enum MKBXDReminderType: Int {
    /// 静音
    case silent = 0
    /// LED
    case led
    /// 震动
    case vibration
    /// 蜂鸣器
    case buzzer
    /// LED + 震动
    case ledAndVibration
    /// LED + 蜂鸣器
    case ledAndBuzzer
}

/// 三轴数据采样率
public enum MKBXDThreeAxisDataRate: Int {
    /// 1Hz
    case rate1Hz = 0
    /// 10Hz
    case rate10Hz
    /// 25Hz
    case rate25Hz
    /// 50Hz
    case rate50Hz
    /// 100Hz
    case rate100Hz
}

/// 三轴加速度量程
public enum MKBXDThreeAxisDataAG: Int {
    /// ±2g
    case ag2g = 0
    /// ±4g
    case ag4g
    /// ±8g
    case ag8g
    /// ±16g
    case ag16g
}

// MARK: - 协议定义

/// 活跃通道广播参数协议
public protocol MKBXDTriggerChannelAdvParamsProtocol: AnyObject {
    /// 告警类型
    var alarmType: MKBXDChannelAlarmType { get set }
    /// 是否启用广播
    var isOn: Bool { get set }
    /// 距离数据（-100dBm~0dBm）
    var rssi: Int { get set }
    /// 广播间隔（1~500，单位 20ms）
    var advInterval: String { get set }
    /// 发射功率
    var txPower: MKBXDTxPower { get set }
}

/// 活跃通道触发广播参数协议
public protocol MKBXDChannelTriggerParamsProtocol: AnyObject {
    /// 告警类型
    var alarmType: MKBXDChannelAlarmType { get set }
    /// 是否启用触发功能
    var alarm: Bool { get set }
    /// 距离数据（-100dBm~0dBm）
    var rssi: Int { get set }
    /// 广播间隔（1~500，单位 20ms）
    var advInterval: String { get set }
    /// 触发后广播时长（1s~65535s）
    var advertisingTime: String { get set }
    /// 发射功率
    var txPower: MKBXDTxPower { get set }
}
