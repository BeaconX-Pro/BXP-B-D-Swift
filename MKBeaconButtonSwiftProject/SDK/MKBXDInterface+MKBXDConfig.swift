//
//  MKBXDInterface+MKBXDConfig.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2025/5/18.
//

import Foundation
@preconcurrency import CoreBluetooth
import MKSwiftBleModule

// MARK: - BXD 配置接口
extension MKBXDInterface {

    // MARK: - 三轴传感器

    /// 配置三轴传感器参数
    /// - Parameters:
    ///   - dataRate: 采样率
    ///   - fullScale: 量程
    ///   - motionThreshold: 运动阈值 1~2048（按 fullScale 不同乘 1/2/4/12 mg）
    public static func bxd_configThreeAxisDataParams(dataRate: MKBXDThreeAxisDataRate,
                                                      fullScale: MKBXDThreeAxisDataAG,
                                                      motionThreshold: Int,
                                                      sucBlock: @escaping () -> Void,
                                                      failedBlock: @escaping (Error) -> Void) {
        if motionThreshold < 1 || motionThreshold > 2048 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let rate = MKBXDAdopter.fetchThreeAxisDataRate(dataRate)
        let ag = MKBXDAdopter.fetchThreeAxisDataAG(fullScale)
        let sen = MKSwiftBleSDKAdopter.fetchHexValue(UInt(motionThreshold), byteLen: 2)
        let commandString = "ea012104" + rate + ag + sen
        configData(withTaskID: .configThreeAxisDataParams,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    // MARK: - 设备基础

    /// 配置设备可连接性
    public static func bxd_configConnectable(_ connectable: Bool,
                                             sucBlock: @escaping () -> Void,
                                             failedBlock: @escaping (Error) -> Void) {
        let commandString = connectable ? "ea01220101" : "ea01220100"
        configData(withTaskID: .configConnectable,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置设备连接密码
    /// - Parameter password: 1~16 ASCII 字符
    public static func bxd_configConnectPassword(_ password: String,
                                                sucBlock: @escaping () -> Void,
                                                failedBlock: @escaping (Error) -> Void) {
        guard !password.isEmpty, password.count <= 16 else {
            operationParamsErrorBlock(failedBlock)
            return
        }
        var commandData = ""
        for scalar in password.unicodeScalars {
            commandData += String(format: "%02lx", Int(scalar.value))
        }
        var lenString = String(format: "%1lx", password.count)
        if lenString.count == 1 {
            lenString = "0" + lenString
        }
        let commandString = "ea0124" + lenString + commandData
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_password else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(.configConnectPassword,
                                                     characteristic: characteristic,
                                                     commandData: commandString,
                                                     successBlock: { returnData in
                                                        if let result = (returnData as? [String: Any])?["result"] as? [String: Any],
                                                           let success = result["success"] as? Bool,
                                                           success {
                                                            sucBlock()
                                                        } else {
                                                            operationSetParamsErrorBlock(failedBlock)
                                                        }
                                                     },
                                                     failureBlock: failedBlock)
    }

    /// 配置连续按键有效时长
    /// - Parameter interval: 5~15（单位 100ms）
    public static func bxd_configEffectiveClickInterval(_ interval: Int,
                                                       sucBlock: @escaping () -> Void,
                                                       failedBlock: @escaping (Error) -> Void) {
        if interval < 5 || interval > 15 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let intervalValue = MKSwiftBleSDKAdopter.fetchHexValue(UInt(interval * 100), byteLen: 2)
        let commandString = "ea012502" + intervalValue
        configData(withTaskID: .configEffectiveClickInterval,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 关机
    public static func bxd_powerOff(sucBlock: @escaping () -> Void,
                                   failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea012600"
        configData(withTaskID: .configPowerOff,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 恢复出厂设置
    public static func bxd_factoryReset(sucBlock: @escaping () -> Void,
                                       failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea012800"
        configData(withTaskID: .configFactoryReset,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置按键开关机状态（仅 BXP-CR）
    public static func bxd_configTurnOffByButton(_ isOn: Bool,
                                                 sucBlock: @escaping () -> Void,
                                                 failedBlock: @escaping (Error) -> Void) {
        let commandString = isOn ? "ea01290101" : "ea01290100"
        configData(withTaskID: .configTurnOffByButton,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 设置回应包开关
    public static func bxd_configScanResponsePacket(_ isOn: Bool,
                                                    sucBlock: @escaping () -> Void,
                                                    failedBlock: @escaping (Error) -> Void) {
        let commandString = isOn ? "ea012f0101" : "ea012f0100"
        configData(withTaskID: .configScanResponsePacket,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 设置按键是否可以恢复出厂设置
    public static func bxd_configResetDeviceByButtonStatus(_ isOn: Bool,
                                                          sucBlock: @escaping () -> Void,
                                                          failedBlock: @escaping (Error) -> Void) {
        let commandString = isOn ? "ea01310101" : "ea01310100"
        configData(withTaskID: .configResetDeviceByButtonStatus,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    // MARK: - 通道广播内容

    /// 配置通道广播内容为告警信息
    public static func bxd_configChannelContentAlarmInfo(_ channelType: MKBXDChannelAlarmType,
                                                        sucBlock: @escaping () -> Void,
                                                        failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea013302" + MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1) + "00"
        configData(withTaskID: .configChannelContent,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置通道广播内容为 UID
    public static func bxd_configChannelContentUID(_ channelType: MKBXDChannelAlarmType,
                                                   namespaceID: String,
                                                   instanceID: String,
                                                   sucBlock: @escaping () -> Void,
                                                   failedBlock: @escaping (Error) -> Void) {
        guard namespaceID.count == 20, MKSwiftBleSDKAdopter.checkHexCharacter(namespaceID),
              instanceID.count == 12, MKSwiftBleSDKAdopter.checkHexCharacter(instanceID) else {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let commandString = "ea013312" + MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1) + "01" + namespaceID + instanceID
        configData(withTaskID: .configChannelContent,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置通道广播内容为 iBeacon
    public static func bxd_configChannelContentBeacon(_ channelType: MKBXDChannelAlarmType,
                                                      major: Int,
                                                      minor: Int,
                                                      uuid: String,
                                                      sucBlock: @escaping () -> Void,
                                                      failedBlock: @escaping (Error) -> Void) {
        guard major >= 0, major <= 65535,
              minor >= 0, minor <= 65535,
              uuid.count == 32,
              MKSwiftBleSDKAdopter.checkHexCharacter(uuid) else {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let commandString = "ea013316" + MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1) + "02" + uuid
                                + MKSwiftBleSDKAdopter.fetchHexValue(UInt(major), byteLen: 2)
                                + MKSwiftBleSDKAdopter.fetchHexValue(UInt(minor), byteLen: 2)
        configData(withTaskID: .configChannelContent,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    // MARK: - 通道广播参数

    /// 配置活跃通道广播参数
    public static func bxd_configTriggerChannelAdvParams(_ params: MKBXDTriggerChannelAdvParamsProtocol,
                                                          sucBlock: @escaping () -> Void,
                                                          failedBlock: @escaping (Error) -> Void) {
        guard MKBXDAdopter.validTriggerChannelAdvParams(params) else {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let commandString = MKBXDAdopter.parseTriggerChannelAdvParams(params)
        configData(withTaskID: .configTriggerChannelAdvParams,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置活跃通道触发广播参数
    public static func bxd_configChannelTriggerParams(_ params: MKBXDChannelTriggerParamsProtocol,
                                                       sucBlock: @escaping () -> Void,
                                                       failedBlock: @escaping (Error) -> Void) {
        guard MKBXDAdopter.validChannelTriggerParams(params) else {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let commandString = MKBXDAdopter.parseChannelTriggerParams(params)
        configData(withTaskID: .configChannelTriggerParams,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置活跃通道触发前广播开关
    public static func bxd_configStayAdvertisingBeforeTriggered(_ channelType: MKBXDChannelAlarmType,
                                                               isOn: Bool,
                                                               sucBlock: @escaping () -> Void,
                                                               failedBlock: @escaping (Error) -> Void) {
        let type = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let commandString = "ea013602" + type + (isOn ? "01" : "00")
        configData(withTaskID: .configStayAdvertisingBeforeTriggered,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置触发提醒模式
    public static func bxd_configAlarmNotificationType(_ channelType: MKBXDChannelAlarmNotifyType,
                                                       reminderType: MKBXDReminderType,
                                                       sucBlock: @escaping () -> Void,
                                                       failedBlock: @escaping (Error) -> Void) {
        let channelTypeHex = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let typeString = MKSwiftBleSDKAdopter.fetchHexValue(UInt(reminderType.rawValue), byteLen: 1)
        let commandString = "ea013702" + channelTypeHex + typeString
        configData(withTaskID: .configAlarmNotificationType,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置异常活动报警静止时间
    /// - Parameter time: 1s~65535s
    public static func bxd_configAbnormalInactivityTime(_ time: Int,
                                                       sucBlock: @escaping () -> Void,
                                                       failedBlock: @escaping (Error) -> Void) {
        if time < 1 || time > 65535 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let timeString = MKSwiftBleSDKAdopter.fetchHexValue(UInt(time), byteLen: 2)
        let commandString = "ea013802" + timeString
        configData(withTaskID: .configAbnormalInactivityTime,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置省电模式开关
    public static func bxd_configPowerSavingMode(_ isOn: Bool,
                                                 sucBlock: @escaping () -> Void,
                                                 failedBlock: @escaping (Error) -> Void) {
        let commandString = isOn ? "ea01390101" : "ea01390100"
        configData(withTaskID: .configPowerSavingMode,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置省电模式静止时间
    /// - Parameter time: 1s~65535s
    public static func bxd_configStaticTriggerTime(_ time: Int,
                                                   sucBlock: @escaping () -> Void,
                                                   failedBlock: @escaping (Error) -> Void) {
        if time < 1 || time > 65535 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let timeString = MKSwiftBleSDKAdopter.fetchHexValue(UInt(time), byteLen: 2)
        let commandString = "ea013a02" + timeString
        configData(withTaskID: .configStaticTriggerTime,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    // MARK: - 触发提醒参数

    /// 配置通道触发 LED 提醒参数
    public static func bxd_configAlarmLEDNotiParams(_ channelType: MKBXDChannelAlarmType,
                                                     blinkingTime: Int,
                                                     blinkingInterval: Int,
                                                     sucBlock: @escaping () -> Void,
                                                     failedBlock: @escaping (Error) -> Void) {
        if blinkingTime < 1 || blinkingTime > 6000 || blinkingInterval < 0 || blinkingInterval > 100 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let channelTypeHex = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let time = MKSwiftBleSDKAdopter.fetchHexValue(UInt(blinkingTime), byteLen: 2)
        let interval = MKSwiftBleSDKAdopter.fetchHexValue(UInt(blinkingInterval), byteLen: 2)
        let commandString = "ea013b05" + channelTypeHex + time + interval
        configData(withTaskID: .configAlarmLEDNotiParams,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置通道触发马达提醒参数
    public static func bxd_configAlarmVibrateNotiParams(_ channelType: MKBXDChannelAlarmType,
                                                         vibratingTime: Int,
                                                         vibratingInterval: Int,
                                                         sucBlock: @escaping () -> Void,
                                                         failedBlock: @escaping (Error) -> Void) {
        if vibratingTime < 1 || vibratingTime > 6000 || vibratingInterval < 0 || vibratingInterval > 100 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let channelTypeHex = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let time = MKSwiftBleSDKAdopter.fetchHexValue(UInt(vibratingTime), byteLen: 2)
        let interval = MKSwiftBleSDKAdopter.fetchHexValue(UInt(vibratingInterval), byteLen: 2)
        let commandString = "ea013c05" + channelTypeHex + time + interval
        configData(withTaskID: .configAlarmVibrateNotiParams,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置通道触发蜂鸣器提醒参数
    public static func bxd_configAlarmBuzzerNotiParams(_ channelType: MKBXDChannelAlarmType,
                                                        ringingTime: Int,
                                                        ringingInterval: Int,
                                                        sucBlock: @escaping () -> Void,
                                                        failedBlock: @escaping (Error) -> Void) {
        if ringingTime < 1 || ringingTime > 6000 || ringingInterval < 0 || ringingInterval > 100 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let channelTypeHex = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let time = MKSwiftBleSDKAdopter.fetchHexValue(UInt(ringingTime), byteLen: 2)
        let interval = MKSwiftBleSDKAdopter.fetchHexValue(UInt(ringingInterval), byteLen: 2)
        let commandString = "ea013d05" + channelTypeHex + time + interval
        configData(withTaskID: .configAlarmBuzzerNotiParams,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置远程 LED 提醒参数
    public static func bxd_configRemoteReminderLEDNotiParams(blinkingTime: Int,
                                                             blinkingInterval: Int,
                                                             sucBlock: @escaping () -> Void,
                                                             failedBlock: @escaping (Error) -> Void) {
        if blinkingTime < 1 || blinkingTime > 6000 || blinkingInterval < 0 || blinkingInterval > 100 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let time = MKSwiftBleSDKAdopter.fetchHexValue(UInt(blinkingTime), byteLen: 2)
        let interval = MKSwiftBleSDKAdopter.fetchHexValue(UInt(blinkingInterval), byteLen: 2)
        let commandString = "ea013e04" + time + interval
        configData(withTaskID: .configRemoteReminderLEDNotiParams,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置远程马达提醒参数（仅 BXP-CR）
    public static func bxd_configRemoteReminderVibrationNotiParams(vibratingTime: Int,
                                                                    vibraingInterval: Int,
                                                                    sucBlock: @escaping () -> Void,
                                                                    failedBlock: @escaping (Error) -> Void) {
        if vibratingTime < 1 || vibratingTime > 6000 || vibraingInterval < 0 || vibraingInterval > 100 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let time = MKSwiftBleSDKAdopter.fetchHexValue(UInt(vibratingTime), byteLen: 2)
        let interval = MKSwiftBleSDKAdopter.fetchHexValue(UInt(vibraingInterval), byteLen: 2)
        let commandString = "ea013f04" + time + interval
        configData(withTaskID: .configRemoteReminderVibrationNotiParams,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置远程蜂鸣器提醒参数
    public static func bxd_configRemoteReminderBuzzerNotiParams(ringingTime: Int,
                                                                 ringingInterval: Int,
                                                                 sucBlock: @escaping () -> Void,
                                                                 failedBlock: @escaping (Error) -> Void) {
        if ringingTime < 1 || ringingTime > 6000 || ringingInterval < 0 || ringingInterval > 100 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let time = MKSwiftBleSDKAdopter.fetchHexValue(UInt(ringingTime), byteLen: 2)
        let interval = MKSwiftBleSDKAdopter.fetchHexValue(UInt(ringingInterval), byteLen: 2)
        let commandString = "ea014004" + time + interval
        configData(withTaskID: .configRemoteReminderBuzzerNotiParams,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    // MARK: - 消警

    /// 远程消警
    public static func bxd_configDismissAlarm(sucBlock: @escaping () -> Void,
                                              failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea014100"
        configData(withTaskID: .configDismissAlarm,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置按键消警使能
    public static func bxd_configDismissAlarmByButton(_ isOn: Bool,
                                                      sucBlock: @escaping () -> Void,
                                                      failedBlock: @escaping (Error) -> Void) {
        let commandString = isOn ? "ea01420101" : "ea01420100"
        configData(withTaskID: .configDismissAlarmByButton,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置远程 LED 消警参数
    public static func bxd_configDismissAlarmLEDNotiParams(time: Int,
                                                           interval: Int,
                                                           sucBlock: @escaping () -> Void,
                                                           failedBlock: @escaping (Error) -> Void) {
        if time < 1 || time > 6000 || interval < 0 || interval > 100 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let timeValue = MKSwiftBleSDKAdopter.fetchHexValue(UInt(time), byteLen: 2)
        let intervalValue = MKSwiftBleSDKAdopter.fetchHexValue(UInt(interval), byteLen: 2)
        let commandString = "ea014304" + timeValue + intervalValue
        configData(withTaskID: .configDismissAlarmLEDNotiParams,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置远程马达消警参数（仅 BXP-CR）
    public static func bxd_configDismissAlarmVibrationNotiParams(time: Int,
                                                                  interval: Int,
                                                                  sucBlock: @escaping () -> Void,
                                                                  failedBlock: @escaping (Error) -> Void) {
        if time < 1 || time > 6000 || interval < 0 || interval > 100 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let timeValue = MKSwiftBleSDKAdopter.fetchHexValue(UInt(time), byteLen: 2)
        let intervalValue = MKSwiftBleSDKAdopter.fetchHexValue(UInt(interval), byteLen: 2)
        let commandString = "ea014404" + timeValue + intervalValue
        configData(withTaskID: .configDismissAlarmVibrationNotiParams,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置远程蜂鸣器消警参数
    public static func bxd_configDismissAlarmBuzzerNotiParams(time: Int,
                                                               interval: Int,
                                                               sucBlock: @escaping () -> Void,
                                                               failedBlock: @escaping (Error) -> Void) {
        if time < 1 || time > 6000 || interval < 0 || interval > 100 {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let timeValue = MKSwiftBleSDKAdopter.fetchHexValue(UInt(time), byteLen: 2)
        let intervalValue = MKSwiftBleSDKAdopter.fetchHexValue(UInt(interval), byteLen: 2)
        let commandString = "ea014504" + timeValue + intervalValue
        configData(withTaskID: .configDismissAlarmBuzzerNotiParams,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置消警提醒模式
    public static func bxd_configDismissAlarmNotificationType(_ type: MKBXDReminderType,
                                                              sucBlock: @escaping () -> Void,
                                                              failedBlock: @escaping (Error) -> Void) {
        let typeString = MKSwiftBleSDKAdopter.fetchHexValue(UInt(type.rawValue), byteLen: 1)
        let commandString = "ea014601" + typeString
        configData(withTaskID: .configDismissAlarmNotificationType,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    // MARK: - 触发记录删除

    /// 删除单击触发记录
    public static func bxd_clearSinglePressEventData(sucBlock: @escaping () -> Void,
                                                     failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea014700"
        configData(withTaskID: .clearSinglePressEventData,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 删除双击触发记录
    public static func bxd_clearDoublePressEventData(sucBlock: @escaping () -> Void,
                                                     failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea014800"
        configData(withTaskID: .clearDoublePressEventData,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 删除长按触发记录
    public static func bxd_clearLongPressEventData(sucBlock: @escaping () -> Void,
                                                   failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea014900"
        configData(withTaskID: .clearLongPressEventData,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置设备时间戳（仅 BXP-CR）
    /// - Parameter timestamp: 毫秒
    public static func bxd_configDeviceTimestamp(_ timestamp: Int64,
                                                 sucBlock: @escaping () -> Void,
                                                 failedBlock: @escaping (Error) -> Void) {
        let value = MKSwiftBleSDKAdopter.fetchHexValue(UInt(timestamp), byteLen: 8)
        let commandString = "ea014b08" + value
        configData(withTaskID: .configDeviceTimestamp,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 删除长链接模式通道触发记录
    public static func bxd_clearLongConnectionModeEventData(sucBlock: @escaping () -> Void,
                                                            failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea014d00"
        configData(withTaskID: .clearLongConnectionModeEventData,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置设备 ID
    /// - Parameter deviceID: 1~6 字节（HEX）
    public static func bxd_configDeviceID(_ deviceID: String,
                                         sucBlock: @escaping () -> Void,
                                         failedBlock: @escaping (Error) -> Void) {
        guard !deviceID.isEmpty, deviceID.count <= 12,
              MKSwiftBleSDKAdopter.checkHexCharacter(deviceID) else {
            operationParamsErrorBlock(failedBlock)
            return
        }
        let len = MKSwiftBleSDKAdopter.fetchHexValue(UInt(deviceID.count / 2), byteLen: 1)
        let commandString = "ea0150" + len + deviceID
        configData(withTaskID: .configDeviceID,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 配置设备名称
    /// - Parameter deviceName: 1~10 ASCII 字符
    public static func bxd_configDeviceName(_ deviceName: String,
                                           sucBlock: @escaping () -> Void,
                                           failedBlock: @escaping (Error) -> Void) {
        guard !deviceName.isEmpty, deviceName.count <= 10 else {
            operationParamsErrorBlock(failedBlock)
            return
        }
        var tempString = ""
        for scalar in deviceName.unicodeScalars {
            tempString += String(format: "%02lx", Int(scalar.value))
        }
        var lenString = String(format: "%1lx", deviceName.count)
        if lenString.count == 1 {
            lenString = "0" + lenString
        }
        let commandString = "ea0151" + lenString + tempString
        configData(withTaskID: .configDeviceName,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 重置电池
    public static func bxd_batteryReset(sucBlock: @escaping () -> Void,
                                        failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea015d00"
        configData(withTaskID: .batteryReset,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 清除副按键单击触发次数
    public static func bxd_clearSubButtonSinglePressEventData(sucBlock: @escaping () -> Void,
                                                               failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea017a00"
        configData(withTaskID: .clearSubBtnSinglePressEventData,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 清除副按键双击触发次数
    public static func bxd_clearSubButtonDoublePressEventData(sucBlock: @escaping () -> Void,
                                                              failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea017b00"
        configData(withTaskID: .clearSubBtnDoublePressEventData,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    /// 清除副按键长按触发次数
    public static func bxd_clearSubButtonLongPressEventData(sucBlock: @escaping () -> Void,
                                                            failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea017c00"
        configData(withTaskID: .clearSubBtnLongPressEventData,
                   data: commandString,
                   sucBlock: sucBlock,
                   failedBlock: failedBlock)
    }

    // MARK: - password

    /// 配置设备连接密码验证开关
    public static func bxd_configPasswordVerification(_ isOn: Bool,
                                                      sucBlock: @escaping () -> Void,
                                                      failedBlock: @escaping (Error) -> Void) {
        let commandString = isOn ? "ea01230101" : "ea01230100"
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_password else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(.configPasswordVerification,
                                                     characteristic: characteristic,
                                                     commandData: commandString,
                                                     successBlock: { returnData in
                                                        if let result = (returnData as? [String: Any])?["result"] as? [String: Any],
                                                           let success = result["success"] as? Bool,
                                                           success {
                                                            sucBlock()
                                                        } else {
                                                            operationSetParamsErrorBlock(failedBlock)
                                                        }
                                                     },
                                                     failureBlock: failedBlock)
    }

    // MARK: - 私有：统一配置入口与错误回调

    /// 通过 bxd_custom 特征发送配置命令的统一封装
    fileprivate static func configData(withTaskID taskID: MKBXDTaskOperationID,
                                       data: String,
                                       sucBlock: @escaping () -> Void,
                                       failedBlock: @escaping (Error) -> Void) {
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_custom else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(taskID,
                                                    characteristic: characteristic,
                                                    commandData: data,
                                                    successBlock: { returnData in
                                                        if let result = (returnData as? [String: Any])?["result"] as? [String: Any],
                                                           let success = result["success"] as? Bool,
                                                           success {
                                                            sucBlock()
                                                        } else {
                                                            operationSetParamsErrorBlock(failedBlock)
                                                        }
                                                    },
                                                    failureBlock: failedBlock)
    }

    /// 参数错误回调
    fileprivate static func operationParamsErrorBlock(_ failedBlock: @escaping (Error) -> Void) {
        let error = NSError(domain: "com.moko.BXDCentralManager",
                             code: -999,
                             userInfo: ["errorInfo": "Data format error"])
        DispatchQueue.main.async {
            failedBlock(error)
        }
    }

    /// 设置参数失败回调
    fileprivate static func operationSetParamsErrorBlock(_ failedBlock: @escaping (Error) -> Void) {
        let error = NSError(domain: "com.moko.BXDCentralManager",
                             code: -999,
                             userInfo: ["errorInfo": "Failed to set parameters"])
        DispatchQueue.main.async {
            failedBlock(error)
        }
    }
}
