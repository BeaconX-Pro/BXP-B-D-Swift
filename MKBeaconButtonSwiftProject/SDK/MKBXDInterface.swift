//
//  MKBXDInterface.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2025/5/18.
//

import Foundation
@preconcurrency import CoreBluetooth
import MKSwiftBleModule

/// BXD 读接口集合
public enum MKBXDInterface {

    // MARK: - Device Service Information

    /// 读取产品型号
    public static func bxd_readDeviceModel(sucBlock: @escaping (Any) -> Void,
                                           failedBlock: @escaping (Error) -> Void) {
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_deviceModel else {
            // 新版本自定义
            readData(withTaskID: .readDeviceModel,
                     cmdFlag: "2e",
                     sucBlock: sucBlock,
                     failedBlock: failedBlock)
            return
        }
        MKBXDCentralManager.shared.addReadTaskWithTaskID(.readDeviceModel,
                                                        characteristic: characteristic,
                                                        successBlock: sucBlock,
                                                        failureBlock: failedBlock)
    }

    /// 读取生产日期
    public static func bxd_readProductionDate(sucBlock: @escaping (Any) -> Void,
                                              failedBlock: @escaping (Error) -> Void) {
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_productionDate else {
            readData(withTaskID: .readProductionDate,
                     cmdFlag: "5a",
                     sucBlock: sucBlock,
                     failedBlock: failedBlock)
            return
        }
        MKBXDCentralManager.shared.addReadTaskWithTaskID(.readProductionDate,
                                                        characteristic: characteristic,
                                                        successBlock: sucBlock,
                                                        failureBlock: failedBlock)
    }

    /// 读取固件版本
    public static func bxd_readFirmware(sucBlock: @escaping (Any) -> Void,
                                        failedBlock: @escaping (Error) -> Void) {
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_firmware else {
            readData(withTaskID: .readFirmware,
                     cmdFlag: "2b",
                     sucBlock: sucBlock,
                     failedBlock: failedBlock)
            return
        }
        MKBXDCentralManager.shared.addReadTaskWithTaskID(.readFirmware,
                                                        characteristic: characteristic,
                                                        successBlock: sucBlock,
                                                        failureBlock: failedBlock)
    }

    /// 读取硬件版本
    public static func bxd_readHardware(sucBlock: @escaping (Any) -> Void,
                                       failedBlock: @escaping (Error) -> Void) {
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_hardware else {
            readData(withTaskID: .readHardware,
                     cmdFlag: "2d",
                     sucBlock: sucBlock,
                     failedBlock: failedBlock)
            return
        }
        MKBXDCentralManager.shared.addReadTaskWithTaskID(.readHardware,
                                                        characteristic: characteristic,
                                                        successBlock: sucBlock,
                                                        failureBlock: failedBlock)
    }

    /// 读取软件版本
    public static func bxd_readSoftware(sucBlock: @escaping (Any) -> Void,
                                       failedBlock: @escaping (Error) -> Void) {
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_software else {
            readData(withTaskID: .readSoftware,
                     cmdFlag: "2c",
                     sucBlock: sucBlock,
                     failedBlock: failedBlock)
            return
        }
        MKBXDCentralManager.shared.addReadTaskWithTaskID(.readSoftware,
                                                        characteristic: characteristic,
                                                        successBlock: sucBlock,
                                                        failureBlock: failedBlock)
    }

    /// 读取厂商信息
    public static func bxd_readManufacturer(sucBlock: @escaping (Any) -> Void,
                                           failedBlock: @escaping (Error) -> Void) {
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_manufacturer else {
            readData(withTaskID: .readManufacturer,
                     cmdFlag: "2a",
                     sucBlock: sucBlock,
                     failedBlock: failedBlock)
            return
        }
        MKBXDCentralManager.shared.addReadTaskWithTaskID(.readManufacturer,
                                                        characteristic: characteristic,
                                                        successBlock: sucBlock,
                                                        failureBlock: failedBlock)
    }

    // MARK: - custom

    /// 读取设备 MAC 地址
    public static func bxd_readMacAddress(sucBlock: @escaping (Any) -> Void,
                                          failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readMacAddress,
                 cmdFlag: "20",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取三轴传感器参数（采样率/量程/阈值）
    public static func bxd_readThreeAxisDataParams(sucBlock: @escaping (Any) -> Void,
                                                   failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readThreeAxisDataParams,
                 cmdFlag: "21",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取设备可连接状态
    public static func bxd_readConnectable(sucBlock: @escaping (Any) -> Void,
                                           failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readConnectable,
                 cmdFlag: "22",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取设备连接密码
    public static func bxd_readConnectPassword(sucBlock: @escaping (Any) -> Void,
                                               failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readConnectPassword,
                 cmdFlag: "24",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取连续按键有效时长
    public static func bxd_readEffectiveClickInterval(sucBlock: @escaping (Any) -> Void,
                                                       failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readEffectiveClickInterval,
                 cmdFlag: "25",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取按键开关机状态（仅 BXP-CR）
    public static func bxd_readTurnOffByButtonStatus(sucBlock: @escaping (Any) -> Void,
                                                     failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readTurnOffByButtonStatus,
                 cmdFlag: "29",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取回应包开关
    public static func bxd_readScanResponsePacket(sucBlock: @escaping (Any) -> Void,
                                                  failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readScanResponsePacket,
                 cmdFlag: "2f",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取按键是否可以恢复出厂设置
    public static func bxd_readResetDeviceByButtonStatus(sucBlock: @escaping (Any) -> Void,
                                                         failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readResetDeviceByButtonStatus,
                 cmdFlag: "31",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取各通道广播使能情况
    public static func bxd_readTriggerChannelState(sucBlock: @escaping (Any) -> Void,
                                                   failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readTriggerChannelState,
                 cmdFlag: "32",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取通道广播帧内容
    public static func bxd_readChannelAdvContent(_ channelType: MKBXDChannelAlarmType,
                                                sucBlock: @escaping (Any) -> Void,
                                                failedBlock: @escaping (Error) -> Void) {
        let type = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let commandString = "ea003301" + type
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_custom else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(.readChannelAdvContent,
                                                    characteristic: characteristic,
                                                    commandData: commandString,
                                                    successBlock: sucBlock,
                                                    failureBlock: failedBlock)
    }

    /// 读取活跃通道广播参数
    public static func bxd_readTriggerChannelAdvParams(_ channelType: MKBXDChannelAlarmType,
                                                       sucBlock: @escaping (Any) -> Void,
                                                       failedBlock: @escaping (Error) -> Void) {
        let type = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let commandString = "ea003401" + type
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_custom else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(.readTriggerChannelAdvParams,
                                                    characteristic: characteristic,
                                                    commandData: commandString,
                                                    successBlock: sucBlock,
                                                    failureBlock: failedBlock)
    }

    /// 读取活跃通道触发广播参数
    public static func bxd_readChannelTriggerParams(_ channelType: MKBXDChannelAlarmType,
                                                    sucBlock: @escaping (Any) -> Void,
                                                    failedBlock: @escaping (Error) -> Void) {
        let type = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let commandString = "ea003501" + type
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_custom else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(.readChannelTriggerParams,
                                                    characteristic: characteristic,
                                                    commandData: commandString,
                                                    successBlock: sucBlock,
                                                    failureBlock: failedBlock)
    }

    /// 读取活跃通道触发前广播开关
    public static func bxd_readStayAdvertisingBeforeTriggered(_ channelType: MKBXDChannelAlarmType,
                                                              sucBlock: @escaping (Any) -> Void,
                                                              failedBlock: @escaping (Error) -> Void) {
        let type = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let commandString = "ea003601" + type
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_custom else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(.readStayAdvertisingBeforeTriggered,
                                                    characteristic: characteristic,
                                                    commandData: commandString,
                                                    successBlock: sucBlock,
                                                    failureBlock: failedBlock)
    }

    /// 读取触发提醒模式
    public static func bxd_readAlarmNotificationType(_ channelType: MKBXDChannelAlarmNotifyType,
                                                    sucBlock: @escaping (Any) -> Void,
                                                    failedBlock: @escaping (Error) -> Void) {
        let type = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let commandString = "ea003701" + type
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_custom else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(.readAlarmNotificationType,
                                                    characteristic: characteristic,
                                                    commandData: commandString,
                                                    successBlock: sucBlock,
                                                    failureBlock: failedBlock)
    }

    /// 读取异常活动报警静止时间
    public static func bxd_readAbnormalInactivityTime(sucBlock: @escaping (Any) -> Void,
                                                      failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readAbnormalInactivityTime,
                 cmdFlag: "38",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取省电模式开关
    public static func bxd_readPowerSavingMode(sucBlock: @escaping (Any) -> Void,
                                               failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readPowerSavingMode,
                 cmdFlag: "39",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取省电模式静止时间
    public static func bxd_readStaticTriggerTime(sucBlock: @escaping (Any) -> Void,
                                                 failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readStaticTriggerTime,
                 cmdFlag: "3a",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取通道触发 LED 提醒参数
    public static func bxd_readAlarmLEDNotiParams(_ channelType: MKBXDChannelAlarmType,
                                                  sucBlock: @escaping (Any) -> Void,
                                                  failedBlock: @escaping (Error) -> Void) {
        let type = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let commandString = "ea003b01" + type
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_custom else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(.readAlarmLEDNotiParams,
                                                    characteristic: characteristic,
                                                    commandData: commandString,
                                                    successBlock: sucBlock,
                                                    failureBlock: failedBlock)
    }

    /// 读取通道触发马达提醒参数（仅 BXP-CR）
    public static func bxd_readAlarmVibrateNotiParams(_ channelType: MKBXDChannelAlarmType,
                                                       sucBlock: @escaping (Any) -> Void,
                                                       failedBlock: @escaping (Error) -> Void) {
        let type = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let commandString = "ea003c01" + type
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_custom else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(.readAlarmVibrateNotiParams,
                                                    characteristic: characteristic,
                                                    commandData: commandString,
                                                    successBlock: sucBlock,
                                                    failureBlock: failedBlock)
    }

    /// 读取通道触发蜂鸣器提醒参数
    public static func bxd_readAlarmBuzzerNotiParams(_ channelType: MKBXDChannelAlarmType,
                                                      sucBlock: @escaping (Any) -> Void,
                                                      failedBlock: @escaping (Error) -> Void) {
        let type = MKSwiftBleSDKAdopter.fetchHexValue(UInt(channelType.rawValue), byteLen: 1)
        let commandString = "ea003d01" + type
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_custom else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(.readAlarmBuzzerNotiParams,
                                                    characteristic: characteristic,
                                                    commandData: commandString,
                                                    successBlock: sucBlock,
                                                    failureBlock: failedBlock)
    }

    /// 读取远程 LED 提醒参数
    public static func bxd_readRemoteReminderLEDNotiParams(sucBlock: @escaping (Any) -> Void,
                                                           failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readRemoteReminderLEDNotiParams,
                 cmdFlag: "3e",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取远程马达提醒参数（仅 BXP-CR）
    public static func bxd_readRemoteReminderVibrationNotiParams(sucBlock: @escaping (Any) -> Void,
                                                                 failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readRemoteReminderVibrationNotiParams,
                 cmdFlag: "3f",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取远程蜂鸣器提醒参数
    public static func bxd_readRemoteReminderBuzzerNotiParams(sucBlock: @escaping (Any) -> Void,
                                                               failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readRemoteReminderBuzzerNotiParams,
                 cmdFlag: "40",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取按键消警使能
    public static func bxd_readDismissAlarmByButton(sucBlock: @escaping (Any) -> Void,
                                                    failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readDismissAlarmByButton,
                 cmdFlag: "42",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取 LED 消警参数
    public static func bxd_readDismissAlarmLEDNotiParams(sucBlock: @escaping (Any) -> Void,
                                                          failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readDismissAlarmLEDNotiParams,
                 cmdFlag: "43",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取马达消警参数（仅 BXP-CR）
    public static func bxd_readDismissAlarmVibrationNotiParams(sucBlock: @escaping (Any) -> Void,
                                                                failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readDismissAlarmVibrationNotiParams,
                 cmdFlag: "44",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取蜂鸣器消警参数
    public static func bxd_readDismissAlarmBuzzerNotiParams(sucBlock: @escaping (Any) -> Void,
                                                            failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readDismissAlarmBuzzerNotiParams,
                 cmdFlag: "45",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取消警提醒模式
    public static func bxd_readDismissAlarmNotificationType(sucBlock: @escaping (Any) -> Void,
                                                            failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readDismissAlarmNotificationType,
                 cmdFlag: "46",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取电池电压
    public static func bxd_readBatteryVoltage(sucBlock: @escaping (Any) -> Void,
                                              failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readBatteryVoltage,
                 cmdFlag: "4a",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取设备时间戳（仅 BXP-CR）
    public static func bxd_readDeviceTimestamp(sucBlock: @escaping (Any) -> Void,
                                               failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readDeviceTimestamp,
                 cmdFlag: "4b",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取传感器状态
    public static func bxd_readSensorStatus(sucBlock: @escaping (Any) -> Void,
                                            failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readSensorStatus,
                 cmdFlag: "4f",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取设备 ID
    public static func bxd_readDeviceID(sucBlock: @escaping (Any) -> Void,
                                        failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readDeviceID,
                 cmdFlag: "50",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取设备名称
    public static func bxd_readDeviceName(sucBlock: @escaping (Any) -> Void,
                                         failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readDeviceName,
                 cmdFlag: "51",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取单击触发次数
    public static func bxd_readSinglePressEventCount(sucBlock: @escaping (Any) -> Void,
                                                     failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readSinglePressEventCount,
                 cmdFlag: "52",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取双击触发次数
    public static func bxd_readDoublePressEventCount(sucBlock: @escaping (Any) -> Void,
                                                     failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readDoublePressEventCount,
                 cmdFlag: "53",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取长按触发次数
    public static func bxd_readLongPressEventCount(sucBlock: @escaping (Any) -> Void,
                                                   failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readLongPressEventCount,
                 cmdFlag: "54",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取设备类型
    public static func bxd_readDeviceType(sucBlock: @escaping (Any) -> Void,
                                         failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readDeviceType,
                 cmdFlag: "57",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取电池实时百分比
    public static func bxd_readDeviceBatteryPercent(sucBlock: @escaping (Any) -> Void,
                                                    failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readDeviceBatteryPercent,
                 cmdFlag: "62",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取板子类型
    public static func bxd_readDevicePCBType(sucBlock: @escaping (Any) -> Void,
                                             failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readDevicePCBType,
                 cmdFlag: "75",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取副按键单击触发次数
    public static func bxd_readSubButtonSinglePressEventCount(sucBlock: @escaping (Any) -> Void,
                                                              failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readSubButtonSinglePressEventCount,
                 cmdFlag: "77",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取副按键双击触发次数
    public static func bxd_readSubButtonDoublePressEventCount(sucBlock: @escaping (Any) -> Void,
                                                              failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readSubButtonDoublePressEventCount,
                 cmdFlag: "78",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    /// 读取副按键长按触发次数
    public static func bxd_readSubButtonLongPressEventCount(sucBlock: @escaping (Any) -> Void,
                                                            failedBlock: @escaping (Error) -> Void) {
        readData(withTaskID: .readSubButtonLongPressEventCount,
                 cmdFlag: "79",
                 sucBlock: sucBlock,
                 failedBlock: failedBlock)
    }

    // MARK: - password

    /// 读取设备是否启用连接密码验证
    public static func bxd_readPasswordVerification(sucBlock: @escaping (Any) -> Void,
                                                   failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea002300"
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_password else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(.readNeedPassword,
                                                    characteristic: characteristic,
                                                    commandData: commandString,
                                                    successBlock: sucBlock,
                                                    failureBlock: failedBlock)
    }

    // MARK: - private

    /// 通过自定义特征发送读取命令的统一封装
    /// - Parameters:
    ///   - taskID: 任务 ID
    ///   - flag: 命令标识（2 字符十六进制）
    ///   - sucBlock: 成功回调
    ///   - failedBlock: 失败回调
    fileprivate static func readData(withTaskID taskID: MKBXDTaskOperationID,
                                     cmdFlag flag: String,
                                     sucBlock: @escaping (Any) -> Void,
                                     failedBlock: @escaping (Error) -> Void) {
        let commandString = "ea00" + flag + "00"
        guard let characteristic = MKBXDCentralManager.shared.peripheral()?.bxd_custom else {
            return
        }
        MKBXDCentralManager.shared.addTaskWithTaskID(taskID,
                                                    characteristic: characteristic,
                                                    commandData: commandString,
                                                    successBlock: sucBlock,
                                                    failureBlock: failedBlock)
    }
}
