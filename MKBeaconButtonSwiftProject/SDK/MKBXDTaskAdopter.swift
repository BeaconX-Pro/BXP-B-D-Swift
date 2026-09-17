//
//  MKBXDTaskAdopter.swift
//  MKBeaconButtonSwiftProject
//
//  Created by aa on 2025/5/18.
//

import Foundation
@preconcurrency import CoreBluetooth
import MKSwiftBleModule

/// BXD 任务数据解析工具
public enum MKBXDTaskAdopter {

    // MARK: - 对外解析入口

    /// 解析读取到的特征数据
    public static func parseReadData(with characteristic: CBCharacteristic) -> [String: Any] {
        guard let readData = characteristic.value else {
            return [:]
        }
        let uuidString = characteristic.uuid.uuidString

        switch uuidString {
        case "2A24":
            // 产品型号
            let tempString = String(data: readData, encoding: .utf8) ?? ""
            return dataParserGetDataSuccess(["modeID": tempString],
                                            operationID: .readDeviceModel)
        case "2A25":
            // 生产日期
            let tempString = String(data: readData, encoding: .utf8) ?? ""
            return dataParserGetDataSuccess(["productionDate": tempString],
                                            operationID: .readProductionDate)
        case "2A26":
            // firmware
            let tempString = String(data: readData, encoding: .utf8) ?? ""
            return dataParserGetDataSuccess(["firmware": tempString],
                                            operationID: .readFirmware)
        case "2A27":
            // hardware
            let tempString = String(data: readData, encoding: .utf8) ?? ""
            return dataParserGetDataSuccess(["hardware": tempString],
                                            operationID: .readHardware)
        case "2A28":
            // software
            let tempString = String(data: readData, encoding: .utf8) ?? ""
            return dataParserGetDataSuccess(["software": tempString],
                                            operationID: .readSoftware)
        case "2A29":
            // manufacturer
            let tempString = String(data: readData, encoding: .utf8) ?? ""
            return dataParserGetDataSuccess(["manufacturer": tempString],
                                            operationID: .readManufacturer)
        case "AA01":
            // custom
            return parseCustomData(readData)
        case "AA07":
            // 密码
            return parsePasswordData(readData)
        default:
            return [:]
        }
    }

    /// 解析写入特征的结果数据（OC 中固定返回空字典）
    public static func parseWriteData(with characteristic: CBCharacteristic) -> [String: Any] {
        return [:]
    }

    // MARK: - 自定义数据解析

    /// 解析 AA01 特征返回的自定义数据
    private static func parseCustomData(_ readData: Data) -> [String: Any] {
        let readString = MKSwiftBleSDKAdopter.hexStringFromData(readData)
        guard readString.count >= 8,
              readString.bleSubstring(from: 0, length: 2) == "eb" else {
            return [:]
        }
        let dataLen = MKSwiftBleSDKAdopter.getDecimalWithHex(readString, range: NSRange(location: 6, length: 2))
        guard readData.count == dataLen + 4 else {
            return [:]
        }
        let flag = readString.bleSubstring(from: 2, length: 2)
        let cmd = readString.bleSubstring(from: 4, length: 2)
        let content = readString.bleSubstring(from: 8, length: dataLen * 2)

        if flag == "00" {
            // 读取
            return parseCustomReadData(content, cmd: cmd, data: readData)
        }
        if flag == "01" {
            // 设置
            return parseCustomConfigData(content, cmd: cmd)
        }
        return [:]
    }

    /// 解析自定义读取数据
    private static func parseCustomReadData(_ content: String, cmd: String, data: Data) -> [String: Any] {
        var operationID: MKBXDTaskOperationID = .default
        var resultDic: [String: Any] = [:]

        switch cmd {
        case "20":
            // 读取 MAC 地址
            operationID = .readMacAddress
            let mac = "\(content.bleSubstring(from: 0, length: 2)):" +
                      "\(content.bleSubstring(from: 2, length: 2)):" +
                      "\(content.bleSubstring(from: 4, length: 2)):" +
                      "\(content.bleSubstring(from: 6, length: 2)):" +
                      "\(content.bleSubstring(from: 8, length: 2)):" +
                      "\(content.bleSubstring(from: 10, length: 2))"
            resultDic = ["macAddress": mac.uppercased()]
        case "21":
            // 读取三轴传感器参数
            operationID = .readThreeAxisDataParams
            resultDic = [
                "samplingRate": content.bleSubstring(from: 0, length: 2),
                "fullScale": content.bleSubstring(from: 2, length: 2),
                "threshold": MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 4, length: 4))
            ]
        case "22":
            // 读取可连接状态
            operationID = .readConnectable
            let connectable = (content == "01")
            resultDic = ["connectable": connectable]
        case "24":
            // 读取设备连接密码
            operationID = .readConnectPassword
            let passwordData = data.subdata(in: 4..<data.count)
            let password = String(data: passwordData, encoding: .utf8) ?? ""
            resultDic = ["password": password]
        case "25":
            // 读取连续按键有效时长
            operationID = .readEffectiveClickInterval
            let interval = MKSwiftBleSDKAdopter.getDecimalWithHex(content, range: NSRange(location: 0, length: 4))
            resultDic = ["interval": String(format: "%ld", interval / 100)]
        case "2a":
            // 读取厂商信息
            operationID = .readManufacturer
            let manufacturerData = data.subdata(in: 4..<data.count)
            let manufacturer = String(data: manufacturerData, encoding: .utf8) ?? ""
            resultDic = ["manufacturer": manufacturer]
        case "2b":
            // 读取固件版本
            operationID = .readFirmware
            let firmwareData = data.subdata(in: 4..<data.count)
            let firmware = String(data: firmwareData, encoding: .utf8) ?? ""
            resultDic = ["firmware": firmware]
        case "2c":
            // 读取软件版本
            operationID = .readSoftware
            let softwareData = data.subdata(in: 4..<data.count)
            let software = String(data: softwareData, encoding: .utf8) ?? ""
            resultDic = ["software": software]
        case "2d":
            // 读取硬件版本
            operationID = .readHardware
            let hardwareData = data.subdata(in: 4..<data.count)
            let hardware = String(data: hardwareData, encoding: .utf8) ?? ""
            resultDic = ["hardware": hardware]
        case "2e":
            // 读取产品型号
            operationID = .readDeviceModel
            let modeIDData = data.subdata(in: 4..<data.count)
            let modeID = String(data: modeIDData, encoding: .utf8) ?? ""
            resultDic = ["modeID": modeID]
        case "29":
            // 读取按键开关机状态
            operationID = .readTurnOffByButtonStatus
            let isOn = (content == "01")
            resultDic = ["isOn": isOn]
        case "2f":
            // 读取回应包开关
            operationID = .readScanResponsePacket
            let isOn = (content == "01")
            resultDic = ["isOn": isOn]
        case "31":
            // 读取按键是否可以恢复出厂设置
            operationID = .readResetDeviceByButtonStatus
            let isOn = (content == "01")
            resultDic = ["isOn": isOn]
        case "32":
            // 读取各通道广播使能情况
            operationID = .readTriggerChannelState
            let singleState = content.bleSubstring(from: 0, length: 2)
            let doubleState = content.bleSubstring(from: 2, length: 2)
            let longState = content.bleSubstring(from: 4, length: 2)
            let inactivityState = content.bleSubstring(from: 6, length: 2)
            resultDic = [
                "singlePressMode": (singleState == "01"),
                "doublePressMode": (doubleState == "01"),
                "longPressMode": (longState == "01"),
                "abnormalInactivityMode": (inactivityState == "01")
            ]
        case "33":
            // 读取通道广播帧内容
            operationID = .readChannelAdvContent
            resultDic = MKBXDAdopter.parseChannelContent(content)
        case "34":
            // 读取活跃通道广播参数
            operationID = .readTriggerChannelAdvParams
            let channelType = content.bleSubstring(from: 0, length: 2)
            let isOn = (content.bleSubstring(from: 2, length: 2) == "01")
            let rssi = MKSwiftBleSDKAdopter.signedHexTurnToInt(content.bleSubstring(from: 4, length: 2))
            let advInterval = MKSwiftBleSDKAdopter.getDecimalWithHex(content, range: NSRange(location: 6, length: 4))
            let txPower = MKBXDAdopter.fetchTxPowerValueString(content.bleSubstring(from: 10, length: 2))
            resultDic = [
                "channelType": channelType,
                "isOn": isOn,
                "rssi": String(format: "%ld", rssi),
                "advInterval": String(format: "%ld", advInterval / 20),
                "txPower": txPower
            ]
        case "35":
            // 读取活跃通道触发广播参数
            operationID = .readChannelTriggerParams
            let channelType = content.bleSubstring(from: 0, length: 2)
            let alarm = (content.bleSubstring(from: 2, length: 2) == "01")
            let rssi = MKSwiftBleSDKAdopter.signedHexTurnToInt(content.bleSubstring(from: 4, length: 2))
            let advInterval = MKSwiftBleSDKAdopter.getDecimalWithHex(content, range: NSRange(location: 6, length: 4))
            let txPower = MKBXDAdopter.fetchTxPowerValueString(content.bleSubstring(from: 10, length: 2))
            let advTime = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 12, length: 4))
            resultDic = [
                "channelType": channelType,
                "alarm": alarm,
                "rssi": String(format: "%ld", rssi),
                "advInterval": String(format: "%ld", advInterval / 20),
                "txPower": txPower,
                "advTime": advTime
            ]
        case "36":
            // 读取活跃通道触发前广播开关
            operationID = .readStayAdvertisingBeforeTriggered
            let channelType = content.bleSubstring(from: 0, length: 2)
            let isOn = (content.bleSubstring(from: 2, length: 2) == "01")
            resultDic = [
                "channelType": channelType,
                "isOn": isOn
            ]
        case "37":
            // 读取触发提醒模式
            operationID = .readAlarmNotificationType
            let channelType = content.bleSubstring(from: 0, length: 2)
            let noteType = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 2, length: 2))
            resultDic = [
                "channelType": channelType,
                "alarmNotificationType": noteType
            ]
        case "38":
            // 读取异常活动报警静止时间
            operationID = .readAbnormalInactivityTime
            let time = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["time": time]
        case "39":
            // 读取省电模式开关
            operationID = .readPowerSavingMode
            let isOn = (content == "01")
            resultDic = ["isOn": isOn]
        case "3a":
            // 读取省电模式静止时间
            operationID = .readStaticTriggerTime
            let time = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["time": time]
        case "3b":
            // 读取通道触发 LED 提醒参数
            operationID = .readAlarmLEDNotiParams
            resultDic = parseChannelNotiParams(content)
        case "3c":
            // 读取通道触发马达提醒参数
            operationID = .readAlarmVibrateNotiParams
            resultDic = parseChannelNotiParams(content)
        case "3d":
            // 读取通道触发蜂鸣器提醒参数
            operationID = .readAlarmBuzzerNotiParams
            resultDic = parseChannelNotiParams(content)
        case "3e":
            // 读取远程 LED 提醒参数
            operationID = .readRemoteReminderLEDNotiParams
            resultDic = parseRemoteNotiParams(content)
        case "3f":
            // 读取远程马达提醒参数
            operationID = .readRemoteReminderVibrationNotiParams
            resultDic = parseRemoteNotiParams(content)
        case "40":
            // 读取远程蜂鸣器提醒参数
            operationID = .readRemoteReminderBuzzerNotiParams
            resultDic = parseRemoteNotiParams(content)
        case "42":
            // 读取按键消警使能
            operationID = .readDismissAlarmByButton
            let isOn = (content == "01")
            resultDic = ["isOn": isOn]
        case "43":
            // 读取 LED 消警参数
            operationID = .readDismissAlarmLEDNotiParams
            resultDic = parseRemoteNotiParams(content)
        case "44":
            // 读取马达消警参数
            operationID = .readDismissAlarmVibrationNotiParams
            resultDic = parseRemoteNotiParams(content)
        case "45":
            // 读取蜂鸣器消警参数
            operationID = .readDismissAlarmBuzzerNotiParams
            resultDic = parseRemoteNotiParams(content)
        case "46":
            // 读取消警提醒模式
            operationID = .readDismissAlarmNotificationType
            let type = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["type": type]
        case "4a":
            // 读取电池电压
            operationID = .readBatteryVoltage
            let voltage = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["voltage": voltage]
        case "4b":
            // 读取设备当前时间戳
            operationID = .readDeviceTimestamp
            let timestamp = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["timestamp": timestamp]
        case "4f":
            // 读取传感器状态
            operationID = .readSensorStatus
            let bitContent = (content.count == 4) ? String(content.dropFirst(2)) : content
            let bit = MKSwiftBleSDKAdopter.binaryByhex(bitContent)
            let threeAxis = (bit.bleSubstring(from: 7, length: 1) == "1")
            let htSensor = (bit.bleSubstring(from: 6, length: 1) == "1")
            let lightSensor = (bit.bleSubstring(from: 6, length: 1) == "1")
            resultDic = [
                "threeAxis": threeAxis,
                "htSensor": htSensor,
                "lightSensor": lightSensor
            ]
        case "50":
            // 读取 deviceID
            operationID = .readDeviceID
            resultDic = ["deviceID": content]
        case "51":
            // 读取设备名称
            operationID = .readDeviceName
            let nameData = data.subdata(in: 4..<data.count)
            let deviceName = String(data: nameData, encoding: .utf8) ?? ""
            resultDic = ["deviceName": deviceName]
        case "52":
            // 读取单击触发次数
            operationID = .readSinglePressEventCount
            let count = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["count": count]
        case "53":
            // 读取双击触发次数
            operationID = .readDoublePressEventCount
            let count = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["count": count]
        case "54":
            // 读取长按触发次数
            operationID = .readLongPressEventCount
            let count = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["count": count]
        case "57":
            // 读取设备类型
            operationID = .readDeviceType
            resultDic = ["deviceType": content]
        case "5a":
            // 读取生产日期
            operationID = .readProductionDate
            var month = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 4, length: 2))
            if month.count == 1 {
                month = "0" + month
            }
            var day = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 6, length: 2))
            if day.count == 1 {
                day = "0" + day
            }
            let year = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: 4))
            resultDic = ["productionDate": "\(year).\(month).\(day)"]
        case "62":
            // 读取电池实时百分比
            operationID = .readDeviceBatteryPercent
            let percent = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["percent": percent]
        case "75":
            // 读取板子类型
            operationID = .readDevicePCBType
            let type = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["type": type]
        case "77":
            // 读取副按键单击触发次数
            operationID = .readSubButtonSinglePressEventCount
            let count = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["count": count]
        case "78":
            // 读取副按键双击触发次数
            operationID = .readSubButtonDoublePressEventCount
            let count = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["count": count]
        case "79":
            // 读取副按键长按触发次数
            operationID = .readSubButtonLongPressEventCount
            let count = MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: content.count))
            resultDic = ["count": count]
        default:
            break
        }

        return dataParserGetDataSuccess(resultDic, operationID: operationID)
    }

    /// 解析自定义设置数据
    private static func parseCustomConfigData(_ content: String, cmd: String) -> [String: Any] {
        var operationID: MKBXDTaskOperationID = .default
        let success = (content == "aa")

        switch cmd {
        case "21": operationID = .configThreeAxisDataParams
        case "22": operationID = .configConnectable
        case "25": operationID = .configEffectiveClickInterval
        case "26": operationID = .configPowerOff
        case "28": operationID = .configFactoryReset
        case "29": operationID = .configTurnOffByButton
        case "2f": operationID = .configScanResponsePacket
        case "31": operationID = .configResetDeviceByButtonStatus
        case "33": operationID = .configChannelContent
        case "34": operationID = .configTriggerChannelAdvParams
        case "35": operationID = .configChannelTriggerParams
        case "36": operationID = .configStayAdvertisingBeforeTriggered
        case "37": operationID = .configAlarmNotificationType
        case "38": operationID = .configAbnormalInactivityTime
        case "39": operationID = .configPowerSavingMode
        case "3a": operationID = .configStaticTriggerTime
        case "3b": operationID = .configAlarmLEDNotiParams
        case "3c": operationID = .configAlarmVibrateNotiParams
        case "3d": operationID = .configAlarmBuzzerNotiParams
        case "3e": operationID = .configRemoteReminderLEDNotiParams
        case "3f": operationID = .configRemoteReminderVibrationNotiParams
        case "40": operationID = .configRemoteReminderBuzzerNotiParams
        case "41": operationID = .configDismissAlarm
        case "42": operationID = .configDismissAlarmByButton
        case "43": operationID = .configDismissAlarmLEDNotiParams
        case "44": operationID = .configDismissAlarmVibrationNotiParams
        case "45": operationID = .configDismissAlarmBuzzerNotiParams
        case "46": operationID = .configDismissAlarmNotificationType
        case "47": operationID = .clearSinglePressEventData
        case "48": operationID = .clearDoublePressEventData
        case "49": operationID = .clearLongPressEventData
        case "4b": operationID = .configDeviceTimestamp
        case "4d": operationID = .clearLongConnectionModeEventData
        case "50": operationID = .configDeviceID
        case "51": operationID = .configDeviceName
        case "5d": operationID = .batteryReset
        case "7a": operationID = .clearSubBtnSinglePressEventData
        case "7b": operationID = .clearSubBtnDoublePressEventData
        case "7c": operationID = .clearSubBtnLongPressEventData
        default: break
        }

        return dataParserGetDataSuccess(["success": success], operationID: operationID)
    }

    /// 解析密码特征数据
    private static func parsePasswordData(_ readData: Data) -> [String: Any] {
        let readString = MKSwiftBleSDKAdopter.hexStringFromData(readData)
        guard readString.count >= 8,
              readString.bleSubstring(from: 0, length: 2) == "eb" else {
            return [:]
        }
        let dataLen = MKSwiftBleSDKAdopter.getDecimalWithHex(readString, range: NSRange(location: 6, length: 2))
        guard readData.count == dataLen + 4 else {
            return [:]
        }
        let flag = readString.bleSubstring(from: 2, length: 2)
        let cmd = readString.bleSubstring(from: 4, length: 2)
        let content = readString.bleSubstring(from: 8, length: dataLen * 2)

        var operationID: MKBXDTaskOperationID = .default
        var resultDic: [String: Any] = [:]

        if flag == "00" {
            // 读取
            if cmd == "23" {
                // 读取设备连接是否需要密码
                operationID = .readNeedPassword
                resultDic = ["state": content]
            }
        } else if flag == "01" {
            let success = (content == "aa")
            switch cmd {
            case "55":
                // 验证密码
                operationID = .connectPassword
                resultDic = ["success": success]
            case "23":
                // 设置密码验证状态
                operationID = .configPasswordVerification
                resultDic = ["success": success]
            case "24":
                // 设置连接密码
                operationID = .configConnectPassword
            default:
                break
            }
        }

        return dataParserGetDataSuccess(resultDic, operationID: operationID)
    }

    // MARK: - Helper

    /// 解析通道触发提醒参数（channelType + time + interval）
    private static func parseChannelNotiParams(_ content: String) -> [String: Any] {
        return [
            "channelType": content.bleSubstring(from: 0, length: 2),
            "time": MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 2, length: 4)),
            "interval": MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 6, length: 4))
        ]
    }

    /// 解析远程提醒参数（time + interval）
    private static func parseRemoteNotiParams(_ content: String) -> [String: Any] {
        return [
            "time": MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 0, length: 4)),
            "interval": MKSwiftBleSDKAdopter.getDecimalStringWithHex(content, range: NSRange(location: 4, length: 4))
        ]
    }

    /// 包装返回数据
    private static func dataParserGetDataSuccess(_ returnData: [String: Any],
                                                  operationID: MKBXDTaskOperationID) -> [String: Any] {
        return [
            "returnData": returnData,
            "operationID": operationID.rawValue
        ]
    }
}
