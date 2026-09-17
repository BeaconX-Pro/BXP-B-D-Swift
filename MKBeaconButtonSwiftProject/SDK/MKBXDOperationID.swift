//
//  MKBXDOperationID.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2025/5/18.
//

import Foundation

/// BXD 通信任务 ID
public enum MKBXDTaskOperationID: Int {
    case `default` = 0

    // MARK: - 设备基础信息
    /// 读取产品型号
    case readDeviceModel
    /// 读取生产日期
    case readProductionDate
    /// 读取固件版本
    case readFirmware
    /// 读取硬件类型
    case readHardware
    /// 读取软件版本
    case readSoftware
    /// 读取厂商信息
    case readManufacturer

    // MARK: - 密码
    /// 读取设备是否需要连接密码
    case readNeedPassword
    /// 连接密码
    case connectPassword

    // MARK: - custom read
    /// 读取 mac 地址
    case readMacAddress
    /// 读取 3 轴传感器数据
    case readThreeAxisDataParams
    /// 读取设备的可连接状态
    case readConnectable
    /// 读取设备的连接密码
    case readConnectPassword
    /// 读取连续按键有效时长
    case readEffectiveClickInterval
    /// 读取按键开关机状态
    case readTurnOffByButtonStatus
    /// 读取回应包开关
    case readScanResponsePacket
    /// 读取按键是否可以恢复出厂设置
    case readResetDeviceByButtonStatus
    /// 读取各通道广播使能情况
    case readTriggerChannelState
    /// 读取通道广播帧内容
    case readChannelAdvContent
    /// 读取活跃通道广播参数
    case readTriggerChannelAdvParams
    /// 读取活跃通道触发广播参数
    case readChannelTriggerParams
    /// 读取活跃通道触发前广播开关
    case readStayAdvertisingBeforeTriggered
    /// 读取触发提醒模式
    case readAlarmNotificationType
    /// 读取异常活动报警静止时间
    case readAbnormalInactivityTime
    /// 读取省电模式开关
    case readPowerSavingMode
    /// 读取省电模式静止时间
    case readStaticTriggerTime
    /// 读取通道触发 LED 提醒参数
    case readAlarmLEDNotiParams
    /// 读取通道触发马达提醒参数
    case readAlarmVibrateNotiParams
    /// 读取通道触发蜂鸣器提醒参数
    case readAlarmBuzzerNotiParams
    /// 读取远程 LED 提醒参数
    case readRemoteReminderLEDNotiParams
    /// 读取远程马达提醒参数
    case readRemoteReminderVibrationNotiParams
    /// 读取远程蜂鸣器提醒参数
    case readRemoteReminderBuzzerNotiParams
    /// 读取按键消警使能
    case readDismissAlarmByButton
    /// 读取 LED 消警参数
    case readDismissAlarmLEDNotiParams
    /// 读取马达消警参数
    case readDismissAlarmVibrationNotiParams
    /// 读取蜂鸣器消警参数
    case readDismissAlarmBuzzerNotiParams
    /// 读取消警提醒模式
    case readDismissAlarmNotificationType
    /// 读取电池电压
    case readBatteryVoltage
    /// 读取设备当前时间戳
    case readDeviceTimestamp
    /// 读取传感器状态
    case readSensorStatus
    /// 读取 deviceID
    case readDeviceID
    /// 读取设备名称
    case readDeviceName
    /// 读取单击触发次数
    case readSinglePressEventCount
    /// 读取双击触发次数
    case readDoublePressEventCount
    /// 读取长按触发次数
    case readLongPressEventCount
    /// 读取设备类型
    case readDeviceType
    /// 读取电池实时百分比
    case readDeviceBatteryPercent
    /// 读取板子类型
    case readDevicePCBType
    /// 读取副按键单击触发次数
    case readSubButtonSinglePressEventCount
    /// 读取副按键双击触发次数
    case readSubButtonDoublePressEventCount
    /// 读取副按键长按触发次数
    case readSubButtonLongPressEventCount

    // MARK: - custom write
    /// 设置 3 轴传感器参数
    case configThreeAxisDataParams
    /// 设置设备的可连接性
    case configConnectable
    /// 设置连接密码
    case configConnectPassword
    /// 设置连续按键有效时长
    case configEffectiveClickInterval
    /// 关机
    case configPowerOff
    /// 恢复出厂设置
    case configFactoryReset
    /// 配置按键开关机状态
    case configTurnOffByButton
    /// 设置回应包开关
    case configScanResponsePacket
    /// 设置按键是否可以恢复出厂设置
    case configResetDeviceByButtonStatus
    /// 设置通道广播帧类型
    case configChannelContent
    /// 设置活跃通道广播参数
    case configTriggerChannelAdvParams
    /// 设置活跃通道触发广播参数
    case configChannelTriggerParams
    /// 设置活跃通道触发前广播开关
    case configStayAdvertisingBeforeTriggered
    /// 设置触发提醒模式
    case configAlarmNotificationType
    /// 设置异常活动报警静止时间
    case configAbnormalInactivityTime
    /// 设置省电模式开关
    case configPowerSavingMode
    /// 设置省电模式静止时间
    case configStaticTriggerTime
    /// 设置通道触发 LED 提醒参数
    case configAlarmLEDNotiParams
    /// 设置通道触发马达提醒参数
    case configAlarmVibrateNotiParams
    /// 设置通道触发蜂鸣器提醒参数
    case configAlarmBuzzerNotiParams
    /// 设置远程 LED 提醒参数
    case configRemoteReminderLEDNotiParams
    /// 设置远程马达提醒参数
    case configRemoteReminderVibrationNotiParams
    /// 设置远程蜂鸣器提醒参数
    case configRemoteReminderBuzzerNotiParams
    /// 设置远程消警
    case configDismissAlarm
    /// 设置按键消警使能
    case configDismissAlarmByButton
    /// 设置远程 LED 消警参数
    case configDismissAlarmLEDNotiParams
    /// 设置远程马达消警参数
    case configDismissAlarmVibrationNotiParams
    /// 设置远程蜂鸣器消警参数
    case configDismissAlarmBuzzerNotiParams
    /// 设置消警提醒模式
    case configDismissAlarmNotificationType
    /// 删除单击通道触发记录
    case clearSinglePressEventData
    /// 删除双击通道触发记录
    case clearDoublePressEventData
    /// 删除长按通道触发记录
    case clearLongPressEventData
    /// 设置设备当前系统时间
    case configDeviceTimestamp
    /// 删除长链接模式通道触发记录
    case clearLongConnectionModeEventData
    /// 设置 deviceID
    case configDeviceID
    /// 设置设备名称
    case configDeviceName
    /// 重置电池
    case batteryReset
    /// 清除副按键单击触发次数
    case clearSubBtnSinglePressEventData
    /// 清除副按键双击触发次数
    case clearSubBtnDoublePressEventData
    /// 清除副按键长按触发次数
    case clearSubBtnLongPressEventData

    // MARK: - password
    /// 设置设备密码验证
    case configPasswordVerification
}
